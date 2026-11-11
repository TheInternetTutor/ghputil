#!/usr/bin/env bash

inspect_local_repository() {
    local current_branch status
    current_branch="$(git -C "$PROJECT_ROOT" branch --show-current)" || { die "Could not determine the current branch."; return 1; }
    [[ -n "$current_branch" ]] || { die "Repository is in detached-HEAD state."; return 1; }

    case "$current_branch" in
        main|master) ;;
        *) die "Unsupported current branch '$current_branch'. GHPUtil supports 'main' and 'master'."; return 1 ;;
    esac

    if [[ "$BRANCH" == auto ]]; then
        BRANCH=$current_branch
        log "Automatically selected branch: $BRANCH"
    elif [[ "$current_branch" != "$BRANCH" ]]; then
        die "Configured branch is '$BRANCH', but the current branch is '$current_branch'. Set branch=auto or configure the matching branch."
        return 1
    fi

    LOCAL_HEAD="$(git -C "$PROJECT_ROOT" rev-parse HEAD 2>/dev/null)" || { die "Repository has no commit history."; return 1; }
    LOCAL_HEAD_SHORT="$(git -C "$PROJECT_ROOT" rev-parse --short HEAD)" || { die "Could not abbreviate the latest commit identifier."; return 1; }
    LOCAL_SUBJECT="$(git -C "$PROJECT_ROOT" log -1 --pretty=%s)" || { die "Could not read the latest commit subject."; return 1; }

    git -C "$PROJECT_ROOT" var GIT_AUTHOR_IDENT >/dev/null 2>&1 || { die "Git author identity is not configured."; return 1; }
    git -C "$PROJECT_ROOT" var GIT_COMMITTER_IDENT >/dev/null 2>&1 || { die "Git committer identity is not configured."; return 1; }

    status="$(git -C "$PROJECT_ROOT" status --porcelain)" || { die "Could not inspect working-tree status."; return 1; }
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
        ORIGIN_URL="$(git -C "$PROJECT_ROOT" remote get-url origin)" || { die "Could not read origin URL."; return 1; }
        log "Existing origin: $ORIGIN_URL"
        if [[ "$EXISTING_REMOTE" == stop ]]; then
            die "An origin remote already exists and existing_remote=stop."
            return 1
        fi
        remote_matches_intended_repository "$ORIGIN_URL" || {
            die "Origin points to a different repository. It will not be replaced."
            return 1
        }
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
