#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=../common.sh
source "$SCRIPT_DIR/../common.sh"

VERSION=${VERSION:?VERSION is required}

if [[ "$VERSION" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  channel=stable
elif [[ "$VERSION" =~ ^v[0-9]+\.[0-9]+\.[0-9]+-[0-9A-Za-z][0-9A-Za-z.-]*$ ]]; then
  channel=prerelease
else
  die "version must look like v1.2.3 or v1.2.3-rc.1"
fi

log "Release input: version=$VERSION channel=$channel"
write_output version "$VERSION"
write_output channel "$channel"
