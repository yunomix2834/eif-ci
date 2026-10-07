#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=../common.sh
source "$SCRIPT_DIR/../common.sh"

SOURCE_IMAGE=${1:?usage: publish-image.sh SOURCE_IMAGE}
require_cmd docker
: "${EIF_VERSION:?EIF_VERSION is required}"
: "${EIF_CHANNEL:?EIF_CHANNEL is required}"
: "${EIF_GHCR_IMAGE:?EIF_GHCR_IMAGE is required}"
: "${EIF_DOCKERHUB_IMAGE:?EIF_DOCKERHUB_IMAGE is required}"

publish_tag() {
  local target=$1
  log "Publishing $target"
  docker tag "$SOURCE_IMAGE" "$target"
  docker push "$target"
}

publish_tag "$EIF_GHCR_IMAGE:$EIF_VERSION"
publish_tag "$EIF_DOCKERHUB_IMAGE:$EIF_VERSION"

if [[ "$EIF_CHANNEL" == "stable" ]]; then
  publish_tag "$EIF_GHCR_IMAGE:latest"
  publish_tag "$EIF_DOCKERHUB_IMAGE:latest"
fi
