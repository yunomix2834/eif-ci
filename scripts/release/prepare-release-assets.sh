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
cat >"$WINDOWS_PORTABLE_DIR/README-WINDOWS.txt" <<'EOF_README'
EIF for Windows
===============

1. Extract EIF-Windows-x64.zip to a normal folder, for example C:\EIF.
2. Double-click EIF.exe.
3. EIF starts the local backend and opens the embedded frontend automatically.
4. Keep the EIF console window open while using the application.
5. If EIF cannot start, it shows a Windows error dialog instead of closing silently.
   The same error is written to %LOCALAPPDATA%\YunoTools\EIF\startup-error.log.

Security defaults:
- EIF listens on 127.0.0.1 by default, so it is local to this computer.
- The session encryption key is generated automatically on first start and
  protected for the current Windows user with Windows DPAPI.

How to Fix Error:
- Open Powershell
- Run this command: Remove-Item "$env:LOCALAPPDATA\YunoTools\EIF\hddtgdt-sessions.enc" -ErrorAction SilentlyContinue
EOF_README

(
  cd "$WINDOWS_PORTABLE_DIR"
  zip -q -9 "$OUT_DIR/EIF-Windows-x64.zip" EIF.exe README-WINDOWS.txt
)
