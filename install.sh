#!/usr/bin/env bash
# Installer returns a status; it does not call exit or change the caller shell.

install_main() {
    local source_dir dest file
    source_dir="$(realpath "${BASH_SOURCE[0]}")" || { printf 'ERROR: Cannot resolve installer path.\n' >&2; return 1; }
    source_dir="${source_dir%/*}"
    dest="${1:-/dir_bash/ghputil}"

    mkdir -p "$dest" || { printf 'ERROR: Cannot create installation directory: %s\n' "$dest" >&2; return 1; }
    for file in github_publish.sh config.sh validation.sh git_inspection.sh github_api.sh git_publish.sh github-publish.conf.example; do
        [[ -f "$source_dir/$file" ]] || { printf 'ERROR: Missing source file: %s\n' "$source_dir/$file" >&2; return 1; }
        cp -- "$source_dir/$file" "$dest/$file" || { printf 'ERROR: Could not install %s\n' "$file" >&2; return 1; }
    done
    chmod 700 "$dest" || { printf 'ERROR: Could not set directory permissions.\n' >&2; return 1; }
    chmod 600 "$dest"/*.sh || { printf 'ERROR: Could not set script permissions.\n' >&2; return 1; }
    chmod 644 "$dest/github-publish.conf.example" || { printf 'ERROR: Could not set template permissions.\n' >&2; return 1; }
    mkdir -p "$dest/logs" || { printf 'ERROR: Could not create log directory.\n' >&2; return 1; }
    chmod 700 "$dest/logs" || { printf 'ERROR: Could not set log directory permissions.\n' >&2; return 1; }
    printf 'Installed GitHub publisher in: %s\n' "$dest"
    printf 'Source from Bash: source %s/github_publish.sh --help\n' "$dest"
}

install_main "$@"
