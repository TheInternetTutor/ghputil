#!/usr/bin/env bash

inspect_local_repository() {
    local current_branch status
    current_branch="$(git -C "$PROJECT_ROOT" branch --show-current)"
    [[ -n "$current_branch" ]] || die "Repository is in detached-HEAD state."
    [[ "$current_branch" == "$BRANCH" ]] || die "Current branch is '$current_branch'; version 1 supports '$BRANCH' only."

    LOCAL_HEAD="$(git -C "$PROJECT_ROOT" rev-parse HEAD 2>/dev/null)" || die "Repository has no commit history."
    LOCAL_HEAD_SHORT="$(git -C "$PROJECT_ROOT" rev-parse --short HEAD)"
    LOCAL_SUBJECT="$(git -C "$PROJECT_ROOT" log -1 --pretty=%s)"

    git -C "$PROJECT_ROOT" var GIT_AUTHOR_IDENT >/dev/null 2>&1 || die "Git author identity is not configured."
    git -C "$PROJECT_ROOT" var GIT_COMMITTER_IDENT >/dev/null 2>&1 || die "Git committer identity is not configured."

    status="$(git -C "$PROJECT_ROOT" status --porcelain)"
    if [[ -n "$status" ]]; then
        log "Working tree contains uncommitted or untracked files. They will remain untouched and will not be published."
    else
        log "Working tree is clean."
    fi

    log "Local branch: $current_branch"
    log "Latest commit: $LOCAL_HEAD_SHORT — $LOCAL_SUBJECT"
}

inspect_origin_remote() {
    ORIGIN_URL=""
    if git -C "$PROJECT_ROOT" remote get-url origin >/dev/null 2>&1; then
        ORIGIN_URL="$(git -C "$PROJECT_ROOT" remote get-url origin)"
        log "Existing origin: $ORIGIN_URL"
        if [[ "$EXISTING_REMOTE" == stop ]]; then
            die "An origin remote already exists and existing_remote=stop."
        fi
        remote_matches_intended_repository "$ORIGIN_URL" || die "Origin points to a different repository. It will not be replaced."
        ORIGIN_PRESENT=yes
    else
        ORIGIN_PRESENT=no
        log "No origin remote is configured."
    fi
}

remote_matches_intended_repository() {
    local url=$1 normalized expected
    expected="github.com/${GITHUB_LOGIN}/${REPOSITORY_NAME}"
    normalized="$url"
    normalized="${normalized#git@}"
    normalized="${normalized#ssh://git@}"
    normalized="${normalized#https://}"
    normalized="${normalized#http://}"
    normalized="${normalized/github.com:/github.com/}"
    normalized="${normalized%/}"
    normalized="${normalized%.git}"
    [[ "${normalized,,}" == "${expected,,}" ]]
}
