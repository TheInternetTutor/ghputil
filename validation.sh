#!/usr/bin/env bash

die() {
    log "ERROR: $*" 2>/dev/null || printf 'ERROR: %s\n' "$*" >&2
    exit 1
}

log() {
    local message
    message="[$(date '+%Y-%m-%d %H:%M:%S %Z')] $*"
    printf '%s\n' "$message"
    if [[ -n "${LOG_FILE:-}" ]]; then
        printf '%s\n' "$message" >> "$LOG_FILE"
    fi
}

validate_enum() {
    local label=$1 value=$2; shift 2
    local allowed
    for allowed in "$@"; do
        [[ "$value" == "$allowed" ]] && return 0
    done
    die "Invalid value '$value' for $label."
}

resolve_project_root() {
    [[ -n "${PROJECT_ARGUMENT:-}" ]] || die "Project directory argument is required."
    [[ -d "$PROJECT_ARGUMENT" ]] || die "Project directory does not exist: $PROJECT_ARGUMENT"
    PROJECT_ROOT="$(git -C "$PROJECT_ARGUMENT" rev-parse --show-toplevel 2>/dev/null)" || die "Not inside a Git working tree: $PROJECT_ARGUMENT"
    PROJECT_ROOT="$(cd -- "$PROJECT_ROOT" && pwd -P)"
}

initialize_logging() {
    local project_key
    project_key="$(printf '%s' "$PROJECT_ROOT" | cksum | awk '{print $1}')"
    LOG_DIR="$SCRIPT_DIR/logs/$(basename -- "$PROJECT_ROOT")-$project_key"
    mkdir -p "$LOG_DIR" || die "Cannot create log directory: $LOG_DIR"
    LOG_FILE="$LOG_DIR/$(date '+%Y%m%d_%H%M%S').log"
    : > "$LOG_FILE" || die "Cannot create log file: $LOG_FILE"
    chmod 600 "$LOG_FILE" 2>/dev/null || true
}

validate_dependencies() {
    local command
    for command in git curl ssh awk sed cksum mktemp; do
        command -v "$command" >/dev/null 2>&1 || die "Required command is missing: $command"
    done
    [[ -n "${HOME:-}" ]] || die "HOME is not set."
}
