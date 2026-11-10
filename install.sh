#!/usr/bin/env bash
set -Eeuo pipefail
SOURCE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
DEST="${1:-/dir_bash/github_publish}"

mkdir -p "$DEST"
for file in github_publish.sh config.sh validation.sh git_inspection.sh github_api.sh git_publish.sh; do
    [[ -f "$SOURCE_DIR/$file" ]] || { printf 'Missing source file: %s\n' "$SOURCE_DIR/$file" >&2; exit 1; }
    cp -- "$SOURCE_DIR/$file" "$DEST/$file"
done
chmod 700 "$DEST"
chmod 700 "$DEST/github_publish.sh"
chmod 600 "$DEST"/*.sh
mkdir -p "$DEST/logs"
chmod 700 "$DEST/logs"
printf 'Installed GitHub publisher in: %s\n' "$DEST"
printf 'Run: %s/github_publish.sh --help\n' "$DEST"
