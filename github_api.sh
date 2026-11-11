#!/usr/bin/env bash

load_github_token() {
    TOKEN_FILE="${HOME}/.config/github/github_pat.txt"
    [[ -r "$TOKEN_FILE" ]] || { die "GitHub PAT file is missing or unreadable: $TOKEN_FILE"; return 1; }
    GH_TOKEN="$(tr -d '\r\n' < "$TOKEN_FILE")" || { die "Could not read GitHub PAT file."; return 1; }
    [[ -n "$GH_TOKEN" ]] || { die "GitHub PAT file is empty."; return 1; }

    API_TMP_DIR="$(mktemp -d)" || { die "Cannot create temporary API directory."; return 1; }
    chmod 700 "$API_TMP_DIR" || { die "Cannot secure temporary API directory."; return 1; }
    API_CONFIG="$API_TMP_DIR/curl.conf"
    API_BODY="$API_TMP_DIR/body.json"
    # Token is kept in a mode-600 temporary curl config, not in curl's argv.
    {
        printf 'silent\nshow-error\n'
        printf 'header = "Accept: application/vnd.github+json"\n'
        printf 'header = "Authorization: Bearer %s"\n' "$GH_TOKEN"
        printf 'header = "X-GitHub-Api-Version: 2022-11-28"\n'
    } > "$API_CONFIG" || { unset GH_TOKEN; die "Could not write temporary API configuration."; return 1; }
    chmod 600 "$API_CONFIG" || { unset GH_TOKEN; die "Could not secure temporary API configuration."; return 1; }
    unset GH_TOKEN
}

cleanup_api_temp() {
    if [[ -n "${API_TMP_DIR:-}" && -d "$API_TMP_DIR" ]]; then
        rm -rf -- "$API_TMP_DIR"
    fi
    API_TMP_DIR=""
    API_CONFIG=""
    API_BODY=""
}

api_request() {
    local method=$1 url=$2 data=${3:-}
    local -a args
    args=(--config "$API_CONFIG" --request "$method" --output "$API_BODY" --write-out '%{http_code}' "$url")
    if [[ -n "$data" ]]; then
        args+=(--header 'Content-Type: application/json' --data "$data")
    fi
    API_STATUS="$(curl "${args[@]}")" || { die "GitHub API request failed at transport level."; return 1; }
}

github_authenticate() {
    api_request GET "https://api.github.com/user" || return 1
    [[ "$API_STATUS" == 200 ]] || { die "GitHub API authentication failed (HTTP $API_STATUS)."; return 1; }
    GITHUB_LOGIN="$(sed -n 's/.*"login"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$API_BODY" | head -n 1)" || { die "Could not parse GitHub account response."; return 1; }
    [[ -n "$GITHUB_LOGIN" ]] || { die "Could not determine the authenticated GitHub account."; return 1; }
}

check_github_repository() {
    api_request GET "https://api.github.com/repos/$GITHUB_LOGIN/$REPOSITORY_NAME" || return 1
    case "$API_STATUS" in
        200) REPOSITORY_EXISTS=yes ;;
        404) REPOSITORY_EXISTS=no ;;
        *) die "Could not check repository existence (HTTP $API_STATUS): $(api_error_message)"; return 1 ;;
    esac
}

github_create_repository() {
    local private_value payload
    [[ "$VISIBILITY" == private ]] && private_value=true || private_value=false
    payload="$(printf '{"name":"%s","private":%s,"auto_init":false}' "$REPOSITORY_NAME" "$private_value")"
    api_request POST "https://api.github.com/user/repos" "$payload" || return 1
    [[ "$API_STATUS" == 201 ]] || { die "Repository creation failed (HTTP $API_STATUS): $(api_error_message)"; return 1; }
    REPOSITORY_EXISTS=yes
    log "Created GitHub repository: https://github.com/$GITHUB_LOGIN/$REPOSITORY_NAME"
}

api_error_message() {
    sed -n 's/.*"message"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$API_BODY" | head -n 1
}
