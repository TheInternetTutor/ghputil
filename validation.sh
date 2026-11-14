#!/usr/bin/env bash

# Print an error and return failure to the caller. Never terminate the shell.
die() {
    log "ERROR: $*" 2>/dev/null || printf 'ERROR: %s\n' "$*" >&2
    return 1
}

# Select the timestamp palette from the message classification. ANSI colors
# are applied only to the terminal timestamp, never to the message or log file.
log_timestamp_style() {
    local message=$1

    case "$message" in
        ERROR:*|*" failed."*|*" failed:"*|*" failure:"*)
            printf '41;30' ;; # Red background, black foreground.
        WARNING:*|*"warning"*)
            printf '43;30' ;; # Yellow background, black foreground.
        *"Continue with the existing repository?"*)
            printf '43;31' ;; # Yellow background, red foreground.
        *"Inspecting remote branch history."*|*"Creating incremental remote bundle"*)
            printf '44;33' ;; # Blue background, yellow foreground.
        *"Repository published successfully."*|*"Created GitHub repository:"*)
            printf '42;34' ;; # Green background, blue foreground.
        *"PUBLICATION SUCCESSFUL"*|*"Publication verified:"*|*"remote bundle is ready"*|*"Verified remote changes extracted"*|*"Temporary remote bundle deleted"*|*"Dry run completed."*|*"Initialization complete."*)
            printf '42;30' ;; # Green background, black foreground.
        *"Remote repository already exists."*|*"GitHub repository already exists:"*|*"Publication cancelled"*)
            printf '43;30' ;; # Yellow background, black foreground.
        *"Publication unsuccessful."*)
            printf '41;33' ;; # Red background, yellow foreground.
        *"Uncommitted changes detected."*)
            printf '45;30' ;; # Magenta background, black foreground.
        *"Git push operation failed."*)
            printf '41;30' ;; # Red background, black foreground.
        *)
            printf '46;30' ;; # Cyan background, black foreground (information).
    esac
}

log() {
    local timestamp message style rendered_timestamp
    timestamp="[$(date '+%Y-%m-%d %H:%M:%S %Z')]"
    message="$*"
    style="$(log_timestamp_style "$message")"

    if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
        rendered_timestamp="$(printf '\033[%sm%s\033[0m' "$style" "$timestamp")"
    else
        rendered_timestamp=$timestamp
    fi
    printf '%s %s\n' "$rendered_timestamp" "$message"

    # Keep persistent logs free of terminal escape sequences.
    if [[ -n "${LOG_FILE:-}" ]]; then
        printf '%s %s\n' "$timestamp" "$message" >> "$LOG_FILE" || {
            printf 'WARNING: could not append to log file: %s\n' "$LOG_FILE" >&2
        }
    fi
}

# Print a timestamped interactive prompt. The timestamp uses the question
# palette; prompt text and captured log content remain plain text.
log_prompt() {
    local prompt_text=$1
    local timestamp style rendered_timestamp
    timestamp="[$(date '+%Y-%m-%d %H:%M:%S %Z')]"
    style='43;31'
    if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
        rendered_timestamp="$(printf '\033[%sm%s\033[0m' "$style" "$timestamp")"
    else
        rendered_timestamp=$timestamp
    fi
    printf '%s %s' "$rendered_timestamp" "$prompt_text"
    if [[ -n "${LOG_FILE:-}" ]]; then
        printf '%s %s\n' "$timestamp" "$prompt_text" >> "$LOG_FILE" || {
            printf 'WARNING: could not append prompt to log file: %s\n' "$LOG_FILE" >&2
        }
    fi
}

# Run one workflow function and propagate its status. On failure, clean up
# temporary API material but leave the calling shell alive.
run_step() {
    local status
    "$@" || {
        status=$?
        cleanup_api_temp
        return "$status"
    }
}

validate_enum() {
    local label=$1 value=$2
    shift 2
    local allowed
    for allowed in "$@"; do
        [[ "$value" == "$allowed" ]] && return 0
    done
    die "Invalid value '$value' for $label."
}

resolve_project_root() {
    [[ -n "${PROJECT_ARGUMENT:-}" ]] || {
        die "Project directory argument is required."
        return 1
    }

    [[ -d "$PROJECT_ARGUMENT" ]] || {
        die "Project directory does not exist: $PROJECT_ARGUMENT"
        return 1
    }

    PROJECT_ROOT="$(git -C "$PROJECT_ARGUMENT" rev-parse --show-toplevel 2>/dev/null)" || {
        die "Not inside a Git working tree: $PROJECT_ARGUMENT"
        return 1
    }

    PROJECT_ROOT="$(realpath "$PROJECT_ROOT")" || {
        die "Cannot resolve project root."
        return 1
    }
}

initialize_logging() {
    local project_key
    project_key="$(printf '%s' "$PROJECT_ROOT" | cksum | awk '{print $1}')" || {
        die "Could not calculate project log identifier."
        return 1
    }
    LOG_DIR="$SCRIPT_DIR/logs/$(basename -- "$PROJECT_ROOT")-$project_key"
    mkdir -p "$LOG_DIR" || { die "Cannot create log directory: $LOG_DIR"; return 1; }
    LOG_FILE="$LOG_DIR/$(date '+%Y%m%d_%H%M%S').log"
    : > "$LOG_FILE" || { die "Cannot create log file: $LOG_FILE"; return 1; }
    chmod 600 "$LOG_FILE" 2>/dev/null || true
}

validate_dependencies() {
    local command
    for command in git curl ssh awk sed cksum mktemp realpath tr cp chmod ln rm tar find wc; do
        command -v "$command" >/dev/null 2>&1 || {
            die "Required command is missing: $command"
            return 1
        }
    done
    [[ -n "${HOME:-}" ]] || { die "HOME is not set."; return 1; }
}
