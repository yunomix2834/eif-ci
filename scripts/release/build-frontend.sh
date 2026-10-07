#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=../common.sh
source "$SCRIPT_DIR/../common.sh"

FRONTEND_DIR=${1:?usage: build-frontend.sh FRONTEND_DIR VERSION}
VERSION=${2:?usage: build-frontend.sh FRONTEND_DIR VERSION}

log "Building final frontend for $VERSION"
(
  cd "$FRONTEND_DIR"
  make install

  export NEXT_PUBLIC_APP_NAME=EIF
  export NEXT_PUBLIC_APP_VERSION="$VERSION"
  export NEXT_PUBLIC_API_BASE_URL=/api/v1
  export NEXT_PUBLIC_SESSION_SYNC_INTERVAL_MS=60000
  export NEXT_PUBLIC_LOG_LEVEL=info

  make build
  [[ -f out/index.html ]] || die "frontend build did not produce out/index.html"
)
