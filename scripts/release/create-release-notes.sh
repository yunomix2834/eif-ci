#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=../common.sh
source "$SCRIPT_DIR/../common.sh"

require_env EIF_VERSION EIF_CHANNEL EIF_BACKEND_SHA EIF_FRONTEND_SHA \
  EIF_GHCR_IMAGE EIF_DOCKERHUB_IMAGE

OUT=${1:-dist/release/release-notes.md}

cat >"$OUT" <<EOF_NOTES
# EIF $EIF_VERSION

Release channel: **$EIF_CHANNEL**

## Windows

Download **\`EIF-Windows-x64.zip\`**, extract it, then double-click **\`EIF.exe\`**.
EIF starts the local backend, serves the embedded frontend, opens your default browser,
and manages the local session encryption key automatically with Windows DPAPI.

## Linux

Download **\`eif-linux-amd64\`** and make it executable if required.

## Sources

- Backend: \`$EIF_BACKEND_SHA\`
- Frontend: \`$EIF_FRONTEND_SHA\`

## Container

- GHCR: \`$EIF_GHCR_IMAGE:$EIF_VERSION\`
- Docker Hub: \`$EIF_DOCKERHUB_IMAGE:$EIF_VERSION\`

Use **\`SHA256SUMS.txt\`** to verify downloaded release files.
EOF_NOTES
