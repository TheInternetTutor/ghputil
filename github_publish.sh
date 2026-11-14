#!/usr/bin/env bash
# GitHub repository creation and publishing utility.
# No global errexit/exit is used: failures return to the caller without closing
# an interactive shell if this script is sourced.

main() {
    RECOVERY_CREATED=no
    RECOVERY_REF=""
    run_step parse_arguments "$@" || return $?
    if [[ "$HELP" == yes ]]; then
        usage
        return 0
    fi

    run_step resolve_project_root || return $?
    run_step initialize_logging || return $?
    log "GitHub publisher starting."
    log "Project: $PROJECT_ROOT"

    run_step prepare_project_config || return $?
    if [[ "$INIT_ONLY" == yes ]]; then
        return 0
    fi

    run_step load_project_config || return $?
    run_step resolve_effective_config || return $?
    run_step validate_dependencies || return $?
    run_step inspect_local_repository || return $?

    if [[ "$DRY_RUN" == yes ]]; then
        log "DRY RUN: no remote repository or local Git configuration will be modified."
    fi

    run_step load_github_token || return $?
    run_step github_authenticate || return $?
    log "Authenticated GitHub account: $GITHUB_LOGIN"

    run_step inspect_origin_remote || return $?
    run_step check_github_repository || return $?

    if [[ "$REPOSITORY_EXISTS" == yes ]]; then
        log "GitHub repository already exists: $GITHUB_LOGIN/$REPOSITORY_NAME"
        if [[ "$EXISTING_REPOSITORY" != update ]]; then
            if [[ "$DRY_RUN" == yes ]]; then
                log "DRY RUN: existing-repository policy is 'stop'; a real run would stop without pushing."
                report_dry_run
                cleanup_api_temp
                return 0
            fi
            die "Existing-repository policy is 'stop'. No changes were made."
            cleanup_api_temp
            return 1
        fi
    else
        log "GitHub repository does not exist: $GITHUB_LOGIN/$REPOSITORY_NAME"
        run_step resolve_visibility || return $?
        run_step confirm_repository_creation || return $?
        if [[ "$DRY_RUN" != yes ]]; then
            run_step github_create_repository || return $?
        else
            log "DRY RUN: would create a ${VISIBILITY:-unspecified} GitHub repository."
        fi
    fi

    run_step configure_origin_remote || return $?
    run_step verify_ssh_authentication || return $?

    if [[ "$DRY_RUN" == yes ]]; then
        report_dry_run
        log "Dry run completed."
        cleanup_api_temp
        return 0
    fi

    run_step publish_branch || return $?
    run_step verify_publication || return $?
    report_success
    cleanup_api_temp
    return 0
}

bootstrap() {
    SCRIPT_DIR="$(realpath "${BASH_SOURCE[0]}")" || {
        printf 'ERROR: Cannot resolve script path.\n' >&2
        return 1
    }
    SCRIPT_DIR="${SCRIPT_DIR%/*}"

    # shellcheck source=config.sh
    source "$SCRIPT_DIR/config.sh" || return 1
    # shellcheck source=validation.sh
    source "$SCRIPT_DIR/validation.sh" || return 1
    # shellcheck source=git_inspection.sh
    source "$SCRIPT_DIR/git_inspection.sh" || return 1
    # shellcheck source=github_api.sh
    source "$SCRIPT_DIR/github_api.sh" || return 1
    # shellcheck source=git_publish.sh
    source "$SCRIPT_DIR/git_publish.sh" || return 1

    main "$@"
}

bootstrap "$@"
