#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=../common.sh
source "$SCRIPT_DIR/../common.sh"

require_cmd gh
require_cmd jq
VERSION=${1:?usage: ensure-release-available.sh VERSION}
: "${GH_TOKEN:?GH_TOKEN is required}"
: "${GITHUB_REPOSITORY:?GITHUB_REPOSITORY is required}"

if gh release view "$VERSION" --repo "$GITHUB_REPOSITORY" >/dev/null 2>&1; then
  die "GitHub Release $VERSION already exists"
fi

encoded=$(jq -rn --arg value "$VERSION" '$value | @uri')
if gh api "repos/$GITHUB_REPOSITORY/git/ref/tags/$encoded" >/dev/null 2>&1; then
  die "Git tag $VERSION already exists"
fi

log "Release version $VERSION is available"
