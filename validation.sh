#!/usr/bin/env bash

# Print an error and return failure to the caller. Never terminate the shell.
die() {
    log "ERROR: $*" 2>/dev/null || printf 'ERROR: %s\n' "$*" >&2
    return 1
}

log() {
    local message
    message="[$(date '+%Y-%m-%d %H:%M:%S %Z')] $*"
    printf '%s\n' "$message"
    if [[ -n "${LOG_FILE:-}" ]]; then
        printf '%s\n' "$message" >> "$LOG_FILE" || {
            printf 'WARNING: could not append to log file: %s\n' "$LOG_FILE" >&2
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
    for command in git curl ssh awk sed cksum mktemp realpath tr cp chmod ln rm; do
        command -v "$command" >/dev/null 2>&1 || {
            die "Required command is missing: $command"
            return 1
        }
    done
    [[ -n "${HOME:-}" ]] || { die "HOME is not set."; return 1; }
}
