#!/usr/bin/env bash

HELP=no
DRY_RUN=no
INIT_ONLY=no
PROJECT_ARGUMENT=""
CLI_NAME=""
CLI_VISIBILITY=""
CLI_YES=no
CLI_CONFIRM=no
CLI_EXISTING=""
CLI_CONFIRM_SET=no
CLI_VISIBILITY_SET=no
CLI_EXISTING_SET=no
CLI_NAME_SET=no

# Built-in defaults
CFG_VISIBILITY=""
CFG_CONFIRM_CREATE=yes
CFG_EXISTING_REPOSITORY=stop
CFG_EXISTING_REMOTE=reuse
CFG_BRANCH=auto
CFG_VERIFY_AFTER_PUBLISH=yes

usage() {
    cat <<'USAGE'
Usage:
  github_publish.sh [OPTIONS] PROJECT_DIRECTORY

Options:
  --name NAME                 Override the GitHub repository name
  --visibility public|private Set repository visibility
  --yes                       Authorize repository creation without prompting
  --confirm                   Require interactive creation confirmation
  --existing stop|update      Behavior when the GitHub repository exists
  --dry-run                   Inspect and report without changing remote state
  --init                      Create .github-publish.conf from the installed template and exit
  --help                      Show this help

Configuration:
  PROJECT_DIRECTORY/.github-publish.conf

Command-line options override project configuration.
The utility automatically detects main or master; branch=main or branch=master can be configured explicitly.
USAGE
}

parse_arguments() {
    while (($#)); do
        case "$1" in
            --name)
                (($# >= 2)) || { die "--name requires a value."; return 1; }
                CLI_NAME=$2; CLI_NAME_SET=yes; shift 2 ;;
            --visibility)
                (($# >= 2)) || { die "--visibility requires a value."; return 1; }
                CLI_VISIBILITY=$2; CLI_VISIBILITY_SET=yes; shift 2 ;;
            --yes)
                CLI_YES=yes; shift ;;
            --confirm)
                CLI_CONFIRM=yes; CLI_CONFIRM_SET=yes; shift ;;
            --existing)
                (($# >= 2)) || { die "--existing requires a value."; return 1; }
                CLI_EXISTING=$2; CLI_EXISTING_SET=yes; shift 2 ;;
            --dry-run)
                DRY_RUN=yes; shift ;;
            --init)
                INIT_ONLY=yes; shift ;;
            --help|-h)
                HELP=yes; shift ;;
            --*)
                die "Unknown option: $1"
                return 1 ;;
            *)
                [[ -z "$PROJECT_ARGUMENT" ]] || { die "Only one project directory may be supplied."; return 1; }
                PROJECT_ARGUMENT=$1; shift ;;
        esac
    done

    [[ "$HELP" == yes ]] && return 0
    [[ -n "$PROJECT_ARGUMENT" ]] || { die "A project directory argument is required."; return 1; }
    [[ "$CLI_YES" != yes || "$CLI_CONFIRM_SET" != yes ]] || { die "Do not combine --yes and --confirm."; return 1; }
    if [[ "$INIT_ONLY" == yes ]]; then
        [[ "$DRY_RUN" != yes && "$CLI_NAME_SET" != yes && "$CLI_VISIBILITY_SET" != yes && \
           "$CLI_YES" != yes && "$CLI_CONFIRM_SET" != yes && "$CLI_EXISTING_SET" != yes ]] || {
            die "--init cannot be combined with publishing options."
            return 1
        }
    fi
}

prepare_project_config() {
    CONFIG_FILE="$PROJECT_ROOT/.github-publish.conf"
    CONFIG_TEMPLATE="$SCRIPT_DIR/github-publish.conf.example"

    if [[ -e "$CONFIG_FILE" || -L "$CONFIG_FILE" ]]; then
        [[ -f "$CONFIG_FILE" ]] || { die "Configuration path exists but is not a regular file: $CONFIG_FILE"; return 1; }
        if [[ "$INIT_ONLY" == yes ]]; then
            log "Project configuration already exists; it was not overwritten: $CONFIG_FILE"
            return 0
        fi
        return 0
    fi

    [[ -f "$CONFIG_TEMPLATE" && -r "$CONFIG_TEMPLATE" ]] || {
        die "Configuration template is missing or unreadable: $CONFIG_TEMPLATE"
        return 1
    }

    if [[ "$INIT_ONLY" != yes ]]; then
        [[ -t 0 ]] || {
            die "Project configuration is missing and no interactive terminal is available. Run with --init or create $CONFIG_FILE manually."
            return 1
        }
        printf "Configuration file not found. Create it from the default template? [Y/n] "
        local answer
        IFS= read -r answer || { die "Could not read configuration-initialization response."; return 1; }
        case "$answer" in
            ""|[Yy]|[Yy][Ee][Ss]) ;;
            [Nn]|[Nn][Oo])
                log "Configuration initialization declined; publication cancelled."
                return 1 ;;
            *)
                die "Please answer yes or no. No configuration was created."
                return 1 ;;
        esac
    fi

    local temp_file
    temp_file="$(mktemp "$PROJECT_ROOT/.github-publish.conf.tmp.XXXXXX")" || {
        die "Could not create a temporary configuration file in $PROJECT_ROOT."
        return 1
    }

    if ! cp -- "$CONFIG_TEMPLATE" "$temp_file" || ! chmod 644 "$temp_file"; then
        rm -f -- "$temp_file"
        die "Could not prepare the project configuration from the template."
        return 1
    fi

    # Linking the completed temporary file creates the destination atomically
    # and cannot overwrite a file created concurrently by another process.
    if ! ln -- "$temp_file" "$CONFIG_FILE" 2>/dev/null; then
        rm -f -- "$temp_file"
        if [[ -f "$CONFIG_FILE" ]]; then
            log "Project configuration appeared during initialization; existing file was preserved."
            return 0
        fi
        die "Could not create project configuration: $CONFIG_FILE"
        return 1
    fi
    rm -f -- "$temp_file"
    log "Created project configuration from template: $CONFIG_FILE"

    if [[ "$INIT_ONLY" == yes ]]; then
        log "Initialization complete. No GitHub repository actions were performed."
    fi
}

load_project_config() {
    [[ -f "$CONFIG_FILE" ]] || { die "Project configuration is unavailable: $CONFIG_FILE"; return 1; }

    log "Loading project configuration: $CONFIG_FILE"
    local line key value lineno=0
    while IFS= read -r line || [[ -n "$line" ]]; do
        ((lineno+=1))
        line="${line%%#*}"
        line="${line#"${line%%[![:space:]]*}"}"
        line="${line%"${line##*[![:space:]]}"}"
        [[ -z "$line" ]] && continue
        [[ "$line" == *=* ]] || { die "Invalid configuration syntax at $CONFIG_FILE:$lineno (expected key=value)."; return 1; }
        key="${line%%=*}"
        value="${line#*=}"
        key="${key%"${key##*[![:space:]]}"}"
        value="${value#"${value%%[![:space:]]*}"}"
        value="${value%"${value##*[![:space:]]}"}"

        case "$key" in
            visibility) CFG_VISIBILITY=$value ;;
            confirm_create) CFG_CONFIRM_CREATE=$value ;;
            existing_repository) CFG_EXISTING_REPOSITORY=$value ;;
            existing_remote) CFG_EXISTING_REMOTE=$value ;;
            branch) CFG_BRANCH=$value ;;
            verify_after_publish) CFG_VERIFY_AFTER_PUBLISH=$value ;;
            *) die "Unknown configuration key '$key' at $CONFIG_FILE:$lineno."; return 1 ;;
        esac
    done < "$CONFIG_FILE"
}

resolve_effective_config() {
    VISIBILITY=$CFG_VISIBILITY
    CONFIRM_CREATE=$CFG_CONFIRM_CREATE
    EXISTING_REPOSITORY=$CFG_EXISTING_REPOSITORY
    EXISTING_REMOTE=$CFG_EXISTING_REMOTE
    BRANCH=$CFG_BRANCH
    VERIFY_AFTER_PUBLISH=$CFG_VERIFY_AFTER_PUBLISH

    [[ "$CLI_NAME_SET" == yes ]] && REPOSITORY_NAME=$CLI_NAME
    [[ "$CLI_VISIBILITY_SET" == yes ]] && VISIBILITY=$CLI_VISIBILITY
    [[ "$CLI_EXISTING_SET" == yes ]] && EXISTING_REPOSITORY=$CLI_EXISTING
    [[ "$CLI_YES" == yes ]] && CONFIRM_CREATE=no
    [[ "$CLI_CONFIRM_SET" == yes ]] && CONFIRM_CREATE=yes

    [[ -n "${REPOSITORY_NAME:-}" ]] || REPOSITORY_NAME="$(basename -- "$PROJECT_ROOT")"

    validate_enum visibility "$VISIBILITY" public private "" || return 1
    validate_enum confirm_create "$CONFIRM_CREATE" yes no || return 1
    validate_enum existing_repository "$EXISTING_REPOSITORY" stop update || return 1
    validate_enum existing_remote "$EXISTING_REMOTE" reuse stop || return 1
    validate_enum branch "$BRANCH" auto main master || return 1
    validate_enum verify_after_publish "$VERIFY_AFTER_PUBLISH" yes no || return 1

    [[ "$REPOSITORY_NAME" =~ ^[A-Za-z0-9._-]+$ ]] || { die "Invalid repository name '$REPOSITORY_NAME'. Use letters, numbers, dots, underscores, or hyphens."; return 1; }
    [[ "$REPOSITORY_NAME" != "." && "$REPOSITORY_NAME" != ".." ]] || { die "Invalid repository name."; return 1; }
    log "Effective settings: name=$REPOSITORY_NAME visibility=${VISIBILITY:-prompt} existing_repository=$EXISTING_REPOSITORY branch=$BRANCH verify=$VERIFY_AFTER_PUBLISH"
}

resolve_visibility() {
    [[ -n "$VISIBILITY" ]] && return 0
    [[ "$DRY_RUN" == yes ]] && { log "Visibility is not configured; a real run would prompt for public or private."; return 0; }
    [[ -t 0 ]] || { die "Visibility is not configured and no interactive terminal is available. Set visibility in .github-publish.conf or use --visibility."; return 1; }
    printf "Repository visibility [public/private]: "
    IFS= read -r VISIBILITY || { die "Could not read repository visibility."; return 1; }
    validate_enum visibility "$VISIBILITY" public private
}

confirm_repository_creation() {
    [[ "$CONFIRM_CREATE" == no ]] && { log "Repository creation authorized by configuration or command line."; return 0; }
    [[ "$DRY_RUN" == yes ]] && { log "DRY RUN: a real run would request confirmation before creating the repository."; return 0; }
    [[ -t 0 ]] || { die "Repository creation requires confirmation. Use --yes or set confirm_create=no."; return 1; }
    printf "Create GitHub repository '%s/%s' (%s)? [y/N] " "$GITHUB_LOGIN" "$REPOSITORY_NAME" "$VISIBILITY"
    local answer
    IFS= read -r answer || { die "Could not read repository-creation confirmation."; return 1; }
    [[ "$answer" =~ ^[Yy]([Ee][Ss])?$ ]] || { die "Repository creation was not authorized."; return 1; }
}
