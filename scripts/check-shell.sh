#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

while IFS= read -r -d '' script; do
  bash -n "$script"
done < <(find "$SCRIPT_DIR" -type f -name '*.sh' -print0)

log "Shell syntax: OK"
