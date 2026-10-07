#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=../common.sh
source "$SCRIPT_DIR/../common.sh"

OUT_DIR=${1:-dist/release}
[[ -d "$OUT_DIR" ]] || die "release directory not found: $OUT_DIR"

(
  cd "$OUT_DIR"
  find . -maxdepth 1 -type f \
    ! -name SHA256SUMS.txt \
    ! -name release-notes.md \
    -printf '%f\0' \
    | sort -z \
    | xargs -0 sha256sum >SHA256SUMS.txt
)
