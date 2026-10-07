#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=../common.sh
source "$SCRIPT_DIR/../common.sh"

require_cmd gh
require_cmd jq

REPO=${1:?usage: resolve-ref.sh REPO REF OUTPUT_NAME}
REF=${2:?usage: resolve-ref.sh REPO REF OUTPUT_NAME}
OUTPUT_NAME=${3:?usage: resolve-ref.sh REPO REF OUTPUT_NAME}
: "${GH_TOKEN:?GH_TOKEN is required}"
: "${EIF_GITHUB_OWNER:?EIF_GITHUB_OWNER is required}"

encoded_ref=$(jq -rn --arg value "$REF" '$value | @uri')
sha=$(gh api "repos/$EIF_GITHUB_OWNER/$REPO/commits/$encoded_ref" --jq '.sha')
[[ "$sha" =~ ^[0-9a-f]{40}$ ]] || die "GitHub returned an invalid SHA for $REPO@$REF"

log "$REPO@$REF -> $sha"
write_output "$OUTPUT_NAME" "$sha"
printf '%s\n' "$sha"
