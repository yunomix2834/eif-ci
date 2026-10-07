#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=../common.sh
source "$SCRIPT_DIR/../common.sh"

require_cmd gh

: "${EIF_VERSION:?EIF_VERSION is required}"
: "${EIF_CHANNEL:?EIF_CHANNEL is required}"
: "${EIF_ORCHESTRATOR_SHA:?EIF_ORCHESTRATOR_SHA is required}"
: "${GITHUB_REPOSITORY:?GITHUB_REPOSITORY is required}"
: "${GH_TOKEN:?GH_TOKEN is required}"

OUT_DIR=${1:-dist/release}
NOTES="$OUT_DIR/release-notes.md"
[[ -f "$NOTES" ]] || die "release notes not found: $NOTES"

args=(
  release create "$EIF_VERSION"
  --repo "$GITHUB_REPOSITORY"
  --target "$EIF_ORCHESTRATOR_SHA"
  --title "EIF $EIF_VERSION"
  --notes-file "$NOTES"
  "$OUT_DIR/EIF-Windows-x64.zip"
  "$OUT_DIR/eif-linux-amd64"
  "$OUT_DIR/SHA256SUMS.txt"
)

if [[ "$EIF_CHANNEL" == "prerelease" ]]; then
  args+=(--prerelease)
fi

log "Creating GitHub Release $EIF_VERSION"
gh "${args[@]}"
