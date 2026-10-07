#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=../common.sh
source "$SCRIPT_DIR/../common.sh"

require_cmd gh
require_cmd jq

REPO=${1:?usage: require-ci-success.sh REPO SHA}
SHA=${2:?usage: require-ci-success.sh REPO SHA}
: "${GH_TOKEN:?GH_TOKEN is required}"
: "${EIF_GITHUB_OWNER:?EIF_GITHUB_OWNER is required}"

[[ "$SHA" =~ ^[0-9a-f]{40}$ ]] || die "SHA must be a full 40-character lowercase commit"

log "Checking CI for $EIF_GITHUB_OWNER/$REPO@$SHA"
runs=$(gh api --method GET \
  "repos/$EIF_GITHUB_OWNER/$REPO/actions/workflows/ci.yml/runs" \
  -f head_sha="$SHA" \
  -f status=completed \
  -f per_page=20)

success_count=$(jq --arg sha "$SHA" \
  '[.workflow_runs[]? | select(.head_sha == $sha and .conclusion == "success")] | length' \
  <<<"$runs")

[[ "$success_count" -gt 0 ]] || die "no successful ci.yml run found for $REPO@$SHA"
log "CI passed for $REPO@$SHA"
