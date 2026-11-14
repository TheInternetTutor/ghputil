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

publish_branch() {
    local remote_line remote_sha remote_ref base_sha
    remote_ref="refs/heads/$BRANCH"
    remote_line="$(git -C "$PROJECT_ROOT" ls-remote origin "$remote_ref")" || { die "Could not inspect the remote branch."; return 1; }
    remote_sha="${remote_line%%[[:space:]]*}"

    if [[ -z "$remote_sha" ]]; then
        log "Remote branch does not exist; a normal initial push is eligible."
    else
        [[ "$EXISTING_REPOSITORY" == update ]] || { die "Remote branch already exists; update was not authorized."; return 1; }
        if [[ "$remote_sha" == "$LOCAL_HEAD" ]]; then
            log "Remote branch already points to the local commit; no push is necessary."
            return 0
        fi

        RECOVERY_REF="refs/ghputil/recovery/${BRANCH}-$$"
        git -C "$PROJECT_ROOT" fetch --no-tags "$ORIGIN_URL" "$remote_ref:$RECOVERY_REF" || {
            git -C "$PROJECT_ROOT" update-ref -d "$RECOVERY_REF" 2>/dev/null || true
            RECOVERY_REF=""
            die "Could not retrieve the remote branch objects for comparison."
            return 1
        }
        remote_sha="$(git -C "$PROJECT_ROOT" rev-parse "$RECOVERY_REF^{commit}")" || {
            git -C "$PROJECT_ROOT" update-ref -d "$RECOVERY_REF" 2>/dev/null || true
            RECOVERY_REF=""
            die "Could not resolve the fetched remote commit."
            return 1
        }

        base_sha="$(git -C "$PROJECT_ROOT" merge-base "$LOCAL_HEAD" "$remote_sha" 2>/dev/null)" || {
            git -C "$PROJECT_ROOT" update-ref -d "$RECOVERY_REF" 2>/dev/null || true
            RECOVERY_REF=""
            die "Local and remote histories have no common ancestor. Automatic recovery is not supported; no files were changed."
            return 1
        }

        if git -C "$PROJECT_ROOT" merge-base --is-ancestor "$remote_sha" "$LOCAL_HEAD"; then
            log "Remote branch is behind local $BRANCH; local history can be published normally."
            git -C "$PROJECT_ROOT" update-ref -d "$RECOVERY_REF" || log "WARNING: Could not remove temporary remote-tracking reference $RECOVERY_REF."
            RECOVERY_REF=""
        else
            if git -C "$PROJECT_ROOT" merge-base --is-ancestor "$LOCAL_HEAD" "$remote_sha"; then
                log "Remote branch is ahead of local $BRANCH; remote-only commits were detected."
            else
                log "Local and remote histories have diverged; remote-only commits were detected."
            fi
            create_remote_recovery_bundle "$base_sha" "$remote_sha" "$RECOVERY_REF" || {
                git -C "$PROJECT_ROOT" update-ref -d "$RECOVERY_REF" 2>/dev/null || true
                RECOVERY_REF=""
                return 1
            }
            return 0
        fi
    fi

    log "Publishing $BRANCH at $LOCAL_HEAD_SHORT."
    git -C "$PROJECT_ROOT" push -u origin "$BRANCH" || { die "Git push failed."; return 1; }
}

create_remote_recovery_bundle() {
    local base_sha=$1 remote_sha=$2 remote_ref=$3
    local bundle_file="$PROJECT_ROOT/GHPUtil-Remote.bundle"
    local recovery_dir="$PROJECT_ROOT/GHPUtil-Remote"
    local temp_dir temp_repo path_file status_file bundle_remote_sha
    local -a changed_paths=() archive_pathspecs=()

    [[ ! -e "$bundle_file" && ! -L "$bundle_file" ]] || {
        die "Recovery bundle destination already exists; refusing to overwrite: $bundle_file"
        return 1
    }
    [[ ! -e "$recovery_dir" && ! -L "$recovery_dir" ]] || {
        die "Recovery extraction directory already exists; refusing to overwrite: $recovery_dir"
        return 1
    }

    temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/ghputil-recovery.XXXXXX")" || {
        die "Could not create a temporary recovery workspace."
        return 1
    }
    temp_repo="$temp_dir/repository.git"
    path_file="$temp_dir/changed-paths"
    status_file="$temp_dir/change-status"

    log "Creating incremental remote bundle from common ancestor $base_sha."
    if ! git -C "$PROJECT_ROOT" bundle create "$bundle_file" "$remote_ref" "^$base_sha"; then
        rm -rf -- "$temp_dir"
        die "Could not create the incremental remote bundle."
        return 1
    fi
    if ! git clone --quiet --shared --bare "$PROJECT_ROOT" "$temp_repo"; then
        log "ERROR: Could not prepare a temporary repository for bundle extraction. Bundle retained at $bundle_file."
        rm -rf -- "$temp_dir"
        return 1
    fi
    if ! git -C "$temp_repo" bundle verify "$bundle_file" >/dev/null 2>&1; then
        log "ERROR: Bundle verification failed against the common history. Bundle retained at $bundle_file."
        rm -rf -- "$temp_dir"
        return 1
    fi
    if ! git -C "$temp_repo" fetch --quiet --no-tags "$bundle_file" "$remote_ref"; then
        log "ERROR: Could not retrieve the advertised commit from the incremental bundle. Bundle retained at $bundle_file."
        rm -rf -- "$temp_dir"
        return 1
    fi
    bundle_remote_sha="$(git -C "$temp_repo" rev-parse FETCH_HEAD^{commit})" || {
        log "ERROR: Could not resolve the commit imported from the bundle. Bundle retained at $bundle_file."
        rm -rf -- "$temp_dir"
        return 1
    }
    if [[ "$bundle_remote_sha" != "$remote_sha" ]]; then
        log "ERROR: Bundle commit does not match the inspected remote commit. Bundle retained at $bundle_file."
        rm -rf -- "$temp_dir"
        return 1
    fi

    git -C "$temp_repo" diff --name-only -z --diff-filter=ACMRT "$base_sha" "$bundle_remote_sha" > "$path_file" || {
        log "ERROR: Could not enumerate remote changed paths. Bundle retained at $bundle_file."
        rm -rf -- "$temp_dir"
        return 1
    }
    git -C "$temp_repo" diff --name-status --find-renames "$base_sha" "$bundle_remote_sha" > "$status_file" || {
        log "ERROR: Could not create the remote change manifest. Bundle retained at $bundle_file."
        rm -rf -- "$temp_dir"
        return 1
    }

    while IFS= read -r -d '' path; do
        changed_paths+=("$path")
        archive_pathspecs+=(":(literal)$path")
    done < "$path_file"

    if ! mkdir -- "$recovery_dir"; then
        log "ERROR: Could not create recovery extraction directory. Bundle retained at $bundle_file."
        rm -rf -- "$temp_dir"
        return 1
    fi

    if ((${#changed_paths[@]})); then
        if ! (set -o pipefail; git -C "$temp_repo" archive --format=tar "$bundle_remote_sha" -- "${archive_pathspecs[@]}" | tar -xf - -C "$recovery_dir"); then
            log "ERROR: Remote file extraction failed. Bundle retained at $bundle_file; inspect $recovery_dir before retrying."
            rm -rf -- "$temp_dir"
            return 1
        fi
    fi

    {
        printf 'Remote recovery snapshot\n'
        printf 'Branch: %s\n' "$BRANCH"
        printf 'Common ancestor: %s\n' "$base_sha"
        printf 'Remote commit: %s\n' "$bundle_remote_sha"
        printf 'Local commit at detection: %s\n' "$LOCAL_HEAD"
        printf '\nChange status (Git name-status format):\n'
        cat "$status_file"
    } > "$recovery_dir/GHPUtil-Remote-Manifest.txt" || {
        log "ERROR: Could not write recovery manifest. Bundle retained at $bundle_file; extracted files remain at $recovery_dir."
        rm -rf -- "$temp_dir"
        return 1
    }

    # Verify that every changed path still exists in the extracted snapshot.
    # Deletions are represented in the manifest and intentionally have no file.
    local path
    for path in "${changed_paths[@]}"; do
        if [[ ! -e "$recovery_dir/$path" && ! -L "$recovery_dir/$path" ]]; then
            log "ERROR: Recovery extraction verification failed for path: $path. Bundle retained at $bundle_file; inspect $recovery_dir."
            rm -rf -- "$temp_dir"
            return 1
        fi
    done

    git -C "$PROJECT_ROOT" update-ref -d "$remote_ref" || log "WARNING: Could not remove temporary remote reference $remote_ref."
    RECOVERY_REF=""

    if rm -f -- "$bundle_file"; then
        log "Verified remote changes extracted to: $recovery_dir"
        log "Temporary remote bundle deleted after successful extraction."
        rm -rf -- "$temp_dir"
        RECOVERY_CREATED=yes
        log "The remote bundle is ready for comparison and integration with the local repository."
        return 0
    fi

    log "ERROR: Extraction succeeded, but the temporary bundle could not be deleted: $bundle_file"
    rm -rf -- "$temp_dir"
    return 1
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
