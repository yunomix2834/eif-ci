#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=../common.sh
source "$SCRIPT_DIR/../common.sh"

require_cmd curl
require_cmd jq
require_cmd base64

BINARY=${1:?usage: smoke-test.sh LINUX_AMD64_BINARY VERSION}
VERSION=${2:?usage: smoke-test.sh LINUX_AMD64_BINARY VERSION}
[[ -x "$BINARY" ]] || die "binary is not executable: $BINARY"

log "Checking build metadata"
version_text=$($BINARY --version)
grep -F "EIF $VERSION" <<<"$version_text" >/dev/null || die "binary version metadata does not match $VERSION"

TMP_DIR=$(mktemp -d)
PORT=${EIF_SMOKE_PORT:-18080}
PID=''
cleanup() {
  if [[ -n "$PID" ]] && kill -0 "$PID" 2>/dev/null; then
    kill "$PID" 2>/dev/null || true
    wait "$PID" 2>/dev/null || true
  fi
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

key=$(head -c 32 /dev/urandom | base64 | tr -d '\n')

log "Starting integrated EIF smoke test on 127.0.0.1:$PORT"
EIF_PORT="$PORT" \
EIF_STATIC_DIR="$TMP_DIR/does-not-exist" \
EIF_SESSION_STORE_PATH="$TMP_DIR/runtime/sessions.enc" \
EIF_SESSION_ENCRYPTION_KEY="$key" \
EIF_LOG_LEVEL=error \
"$BINARY" >"$TMP_DIR/eif.log" 2>&1 &
PID=$!

ready=false
for _ in $(seq 1 40); do
  if curl -fsS "http://127.0.0.1:$PORT/healthz" >"$TMP_DIR/health.json" 2>/dev/null; then
    ready=true
    break
  fi
  sleep 0.25
done

if [[ "$ready" != true ]]; then
  cat "$TMP_DIR/eif.log" >&2 || true
  die "EIF did not become healthy"
fi

[[ "$(jq -r '.status' "$TMP_DIR/health.json")" == "ok" ]] || die "healthz status is not ok"
[[ "$(jq -r '.version' "$TMP_DIR/health.json")" == "$VERSION" ]] || die "healthz version does not match release"

curl -fsS "http://127.0.0.1:$PORT/" >"$TMP_DIR/index.html"
grep -Eiq '<!doctype html|<html' "$TMP_DIR/index.html" || die "root endpoint did not serve embedded frontend HTML"

log "Integrated binary smoke test passed with embedded frontend"
