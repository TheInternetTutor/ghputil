#!/usr/bin/env bash
# GitHub repository creation and publishing utility.
#set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

# shellcheck source=config.sh
source "$SCRIPT_DIR/config.sh"
# shellcheck source=validation.sh
source "$SCRIPT_DIR/validation.sh"
# shellcheck source=git_inspection.sh
source "$SCRIPT_DIR/git_inspection.sh"
# shellcheck source=github_api.sh
source "$SCRIPT_DIR/github_api.sh"
# shellcheck source=git_publish.sh
source "$SCRIPT_DIR/git_publish.sh"

main() {
    parse_arguments "$@"
    [[ "$HELP" == yes ]] && { usage; return 0; }

    resolve_project_root "$PROJECT_ARGUMENT"
    initialize_logging
    log "GitHub publisher starting."
    log "Project: $PROJECT_ROOT"

    load_project_config
    resolve_effective_config
    validate_dependencies
    inspect_local_repository

    if [[ "$DRY_RUN" == yes ]]; then
        log "DRY RUN: no remote repository or local Git configuration will be modified."
    fi

    load_github_token
    github_authenticate
    log "Authenticated GitHub account: $GITHUB_LOGIN"

    inspect_origin_remote
    check_github_repository

    if [[ "$REPOSITORY_EXISTS" == yes ]]; then
        log "GitHub repository already exists: $GITHUB_LOGIN/$REPOSITORY_NAME"
        if [[ "$EXISTING_REPOSITORY" != update ]]; then
            if [[ "$DRY_RUN" == yes ]]; then
                log "DRY RUN: existing-repository policy is 'stop'; a real run would stop without pushing."
                report_dry_run
                return 0
            fi
            die "Existing-repository policy is 'stop'. No changes were made."
        fi
    else
        log "GitHub repository does not exist: $GITHUB_LOGIN/$REPOSITORY_NAME"
        resolve_visibility
        confirm_repository_creation
        if [[ "$DRY_RUN" != yes ]]; then
            github_create_repository
        else
            log "DRY RUN: would create a $VISIBILITY GitHub repository."
        fi
    fi

    configure_origin_remote
    verify_ssh_authentication

    if [[ "$DRY_RUN" == yes ]]; then
        report_dry_run
        log "Dry run completed."
        return 0
    fi

    publish_master
    verify_publication
    report_success
}

main "$@"
