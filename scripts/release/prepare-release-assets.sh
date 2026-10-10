#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=../common.sh
source "$SCRIPT_DIR/../common.sh"

BINARY_DIR=${1:-dist/binaries}
OUT_DIR=${2:-dist/release}

require_cmd zip

WINDOWS_BINARY="$BINARY_DIR/eif-windows-amd64.exe"
LINUX_BINARY="$BINARY_DIR/eif-linux-amd64"
[[ -f "$WINDOWS_BINARY" ]] || die "missing Windows binary: $WINDOWS_BINARY"
[[ -f "$LINUX_BINARY" ]] || die "missing Linux binary: $LINUX_BINARY"

rm -rf "$OUT_DIR" dist/windows-portable
mkdir -p "$OUT_DIR" dist/windows-portable
OUT_DIR=$(cd "$OUT_DIR" && pwd)
WINDOWS_PORTABLE_DIR=$(cd dist/windows-portable && pwd)

cp "$LINUX_BINARY" "$OUT_DIR/eif-linux-amd64"
cp "$WINDOWS_BINARY" "$WINDOWS_PORTABLE_DIR/EIF.exe"
cp "$SCRIPT_DIR/../../templates/README-WINDOWS.txt" "$WINDOWS_PORTABLE_DIR/README-WINDOWS.txt"

(
  cd "$WINDOWS_PORTABLE_DIR"
  zip -q -9 "$OUT_DIR/EIF-Windows-x64.zip" EIF.exe README-WINDOWS.txt
)
