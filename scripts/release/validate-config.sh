#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=../common.sh
source "$SCRIPT_DIR/../common.sh"

: "${EIF_GITHUB_OWNER:?EIF_GITHUB_OWNER is required}"
: "${EIF_BACKEND_REPO:?EIF_BACKEND_REPO is required}"
: "${EIF_FRONTEND_REPO:?EIF_FRONTEND_REPO is required}"
: "${EIF_GHCR_IMAGE:?EIF_GHCR_IMAGE is required}"
: "${EIF_DOCKERHUB_IMAGE:?EIF_DOCKERHUB_IMAGE is required}"

[[ "$EIF_GITHUB_OWNER" =~ ^[A-Za-z0-9_.-]+$ ]] || die "invalid EIF_GITHUB_OWNER"
[[ "$EIF_BACKEND_REPO" =~ ^[A-Za-z0-9_.-]+$ ]] || die "invalid EIF_BACKEND_REPO"
[[ "$EIF_FRONTEND_REPO" =~ ^[A-Za-z0-9_.-]+$ ]] || die "invalid EIF_FRONTEND_REPO"
[[ "$EIF_BACKEND_REPO" != "$EIF_FRONTEND_REPO" ]] || die "backend and frontend repository names must differ"

[[ "$EIF_GHCR_IMAGE" == ghcr.io/*/* ]] || die "EIF_GHCR_IMAGE must look like ghcr.io/owner/image"
[[ "$EIF_DOCKERHUB_IMAGE" != *://* ]] || die "EIF_DOCKERHUB_IMAGE must not include a URL scheme"
[[ "$EIF_DOCKERHUB_IMAGE" == */* ]] || die "EIF_DOCKERHUB_IMAGE must look like owner/image"

if [[ "$EIF_GHCR_IMAGE" != "${EIF_GHCR_IMAGE,,}" ]]; then
  die "EIF_GHCR_IMAGE must be lowercase"
fi
if [[ "$EIF_DOCKERHUB_IMAGE" != "${EIF_DOCKERHUB_IMAGE,,}" ]]; then
  die "EIF_DOCKERHUB_IMAGE must be lowercase"
fi

log "Repository and registry configuration is valid"
