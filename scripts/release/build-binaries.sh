#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=../common.sh
source "$SCRIPT_DIR/../common.sh"

BACKEND_DIR=${1:?usage: build-binaries.sh BACKEND_DIR OUT_DIR}
OUT_DIR=${2:?usage: build-binaries.sh BACKEND_DIR OUT_DIR}

: "${EIF_VERSION:?EIF_VERSION is required}"
: "${EIF_BACKEND_SHA:?EIF_BACKEND_SHA is required}"
: "${EIF_FRONTEND_SHA:?EIF_FRONTEND_SHA is required}"
: "${EIF_ORCHESTRATOR_SHA:?EIF_ORCHESTRATOR_SHA is required}"
: "${EIF_BUILD_TIME:?EIF_BUILD_TIME is required}"

mkdir -p "$OUT_DIR"
OUT_DIR=$(cd "$(dirname "$OUT_DIR")" && pwd)/$(basename "$OUT_DIR")
module_path=$(awk '$1 == "module" {print $2; exit}' "$BACKEND_DIR/go.mod")
[[ -n "$module_path" ]] || die "could not read Go module path"
buildinfo="$module_path/internal/core/buildinfo"

ldflags="-s -w \
-X ${buildinfo}.Version=${EIF_VERSION} \
-X ${buildinfo}.BackendCommit=${EIF_BACKEND_SHA} \
-X ${buildinfo}.FrontendCommit=${EIF_FRONTEND_SHA} \
-X ${buildinfo}.OrchestratorCommit=${EIF_ORCHESTRATOR_SHA} \
-X ${buildinfo}.BuildTime=${EIF_BUILD_TIME}"

build_one() {
  local goos=$1
  local goarch=$2
  local filename=$3

  log "Building $filename"
  (
    cd "$BACKEND_DIR"
    CGO_ENABLED=0 GOOS="$goos" GOARCH="$goarch" \
      go build \
        -trimpath \
        -buildvcs=false \
        -ldflags="$ldflags" \
        -o "$OUT_DIR/$filename" \
        ./cmd/eif
  )
}

build_one windows amd64 eif-windows-amd64.exe
build_one linux amd64 eif-linux-amd64
chmod +x "$OUT_DIR/eif-linux-amd64"
