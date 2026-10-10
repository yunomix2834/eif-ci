#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=../common.sh
source "$SCRIPT_DIR/../common.sh"

require_cmd gh jq
VERSION=${1:?usage: ensure-release-available.sh VERSION}
require_env GH_TOKEN GITHUB_REPOSITORY

if gh release view "$VERSION" --repo "$GITHUB_REPOSITORY" >/dev/null 2>&1; then
  die "GitHub Release $VERSION already exists"
fi

encoded=$(encode_uri_component "$VERSION")
if gh api "repos/$GITHUB_REPOSITORY/git/ref/tags/$encoded" >/dev/null 2>&1; then
  die "Git tag $VERSION already exists"
fi

log "Release version $VERSION is available"
