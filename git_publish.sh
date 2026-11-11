#!/usr/bin/env bash

configure_origin_remote() {
    local target="git@github.com:${GITHUB_LOGIN}/${REPOSITORY_NAME}.git"
    if [[ "$ORIGIN_PRESENT" == yes ]]; then
        log "Reusing existing origin remote."
    elif [[ "$DRY_RUN" == yes ]]; then
        log "DRY RUN: would add origin: $target"
    else
        git -C "$PROJECT_ROOT" remote add origin "$target" || { die "Could not add origin remote."; return 1; }
        ORIGIN_URL=$target
        ORIGIN_PRESENT=yes
        log "Configured origin: $target"
    fi
}

verify_ssh_authentication() {
    local output rc
    if [[ -f "$HOME/.ssh/config" ]]; then
        if output="$(ssh -F "$HOME/.ssh/config" -T git@github.com 2>&1)"; then
            rc=0
        else
            rc=$?
        fi
        printf -v GIT_SSH_COMMAND 'ssh -F %q' "$HOME/.ssh/config"
    else
        if output="$(ssh -T git@github.com 2>&1)"; then
            rc=0
        else
            rc=$?
        fi
        GIT_SSH_COMMAND=ssh
    fi

    # GitHub intentionally returns status 1 because it does not provide shell access.
    if [[ "$output" != *"successfully authenticated"* ]]; then
        log "$output"
        die "SSH authentication to GitHub failed (exit $rc)."
        return 1
    fi
    log "SSH authentication to GitHub succeeded."
    export GIT_SSH_COMMAND
}

publish_master() {
    local remote_line remote_sha
    remote_line="$(git -C "$PROJECT_ROOT" ls-remote origin "refs/heads/$BRANCH")" || { die "Could not inspect the remote branch."; return 1; }
    remote_sha="${remote_line%%[[:space:]]*}"

    if [[ -n "$remote_sha" ]]; then
        [[ "$EXISTING_REPOSITORY" == update ]] || { die "Remote branch already exists; update was not authorized."; return 1; }
        if [[ "$remote_sha" == "$LOCAL_HEAD" ]]; then
            log "Remote branch already points to the local commit; no push is necessary."
            return 0
        fi
        git -C "$PROJECT_ROOT" merge-base --is-ancestor "$remote_sha" "$LOCAL_HEAD" || {
            die "Remote history is not an ancestor of local master. Refusing to push."
            return 1
        }
    fi

    log "Publishing $BRANCH at $LOCAL_HEAD_SHORT."
    git -C "$PROJECT_ROOT" push -u origin "$BRANCH" || { die "Git push failed."; return 1; }
}

verify_publication() {
    [[ "$VERIFY_AFTER_PUBLISH" == yes ]] || { log "Post-publication verification disabled by configuration."; return 0; }
    local remote_line remote_sha
    remote_line="$(git -C "$PROJECT_ROOT" ls-remote origin "refs/heads/$BRANCH")" || { die "Could not verify the published branch."; return 1; }
    remote_sha="${remote_line%%[[:space:]]*}"
    [[ "$remote_sha" == "$LOCAL_HEAD" ]] || { die "Publication verification failed: remote commit does not match local HEAD."; return 1; }
    log "Publication verified: origin/$BRANCH points to $LOCAL_HEAD_SHORT."
}

report_dry_run() {
    log "DRY RUN SUMMARY"
    log "Project root: $PROJECT_ROOT"
    log "Repository: https://github.com/$GITHUB_LOGIN/$REPOSITORY_NAME"
    log "Branch and commit: $BRANCH $LOCAL_HEAD_SHORT"
    log "Repository exists: $REPOSITORY_EXISTS"
    log "Visibility: ${VISIBILITY:-not yet selected}"
    log "No push or remote configuration changes were performed."
}

report_success() {
    log "PUBLICATION SUCCESSFUL"
    log "Repository: https://github.com/$GITHUB_LOGIN/$REPOSITORY_NAME"
    log "Visibility: ${VISIBILITY:-existing repository}"
    log "Branch: $BRANCH"
    log "Commit: $LOCAL_HEAD"
    log "Log file: $LOG_FILE"
}
