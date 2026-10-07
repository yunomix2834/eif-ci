#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=../common.sh
source "$SCRIPT_DIR/../common.sh"

FRONTEND_DIR=${1:?usage: assemble.sh FRONTEND_DIR BACKEND_DIR}
BACKEND_DIR=${2:?usage: assemble.sh FRONTEND_DIR BACKEND_DIR}
TARGET=$(cd "$BACKEND_DIR" && pwd)/web/static

log "Copying frontend/out into backend/web/static"
(
  cd "$FRONTEND_DIR"
  npm run copy:backend -- "$TARGET"
)

[[ -f "$TARGET/index.html" ]] || die "assembled backend is missing web/static/index.html"
log "Frontend and backend assembled successfully"
