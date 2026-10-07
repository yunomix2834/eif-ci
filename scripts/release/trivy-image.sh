#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=../common.sh
source "$SCRIPT_DIR/../common.sh"

IMAGE=${1:?usage: trivy-image.sh IMAGE OUT_DIR}
OUT_DIR=${2:?usage: trivy-image.sh IMAGE OUT_DIR}
mkdir -p "$OUT_DIR"
require_cmd trivy

log "Creating final Linux image vulnerability report"
trivy image \
  --scanners vuln \
  --format json \
  --output "$OUT_DIR/trivy-image.json" \
  "$IMAGE"

log "Creating final Linux image SBOM"
trivy image \
  --scanners vuln \
  --format cyclonedx \
  --output "$OUT_DIR/sbom-image.cdx.json" \
  "$IMAGE"

log "Release gate: fail on CRITICAL vulnerabilities"
trivy image \
  --scanners vuln \
  --severity CRITICAL \
  --exit-code 1 \
  "$IMAGE"

log "Release gate: fail on detected secrets"
trivy image \
  --scanners secret \
  --exit-code 1 \
  --format table \
  "$IMAGE"
