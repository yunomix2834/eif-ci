#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=../common.sh
source "$SCRIPT_DIR/../common.sh"

require_cmd gh jq

REPO=${1:?usage: resolve-ref.sh REPO REF OUTPUT_NAME}
REF=${2:?usage: resolve-ref.sh REPO REF OUTPUT_NAME}
OUTPUT_NAME=${3:?usage: resolve-ref.sh REPO REF OUTPUT_NAME}
require_env GH_TOKEN EIF_GITHUB_OWNER

encoded_ref=$(encode_uri_component "$REF")
sha=$(gh api "repos/$EIF_GITHUB_OWNER/$REPO/commits/$encoded_ref" --jq '.sha')
is_commit_sha "$sha" || die "GitHub returned an invalid SHA for $REPO@$REF"

log "$REPO@$REF -> $sha"
write_output "$OUTPUT_NAME" "$sha"
printf '%s\n' "$sha"
