#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_DIR=$(cd "$SCRIPT_DIR/../.." && pwd)
# shellcheck source=../common.sh
source "$SCRIPT_DIR/../common.sh"

test_dir=$(mktemp -d -t eif-ci-tests.XXXXXX)
trap 'rm -rf -- "$test_dir"' EXIT

assert_contains() {
  local file=$1 expected=$2
  grep -F -- "$expected" "$file" >/dev/null || die "expected '$expected' in $file"
}

log "Checking shared validation helpers"
require_cmd bash printf
EIF_TEST_VALUE=test-only require_env EIF_TEST_VALUE
if (unset EIF_TEST_MISSING; require_env EIF_TEST_MISSING) 2>"$test_dir/error"; then
  die "missing environment variable was accepted"
fi
assert_contains "$test_dir/error" 'EIF_TEST_MISSING is required'
if (require_cmd eif_command_that_does_not_exist) 2>"$test_dir/error"; then
  die "missing command was accepted"
fi
assert_contains "$test_dir/error" 'required command not found'
is_commit_sha 0123456789abcdef0123456789abcdef01234567
if is_commit_sha short-sha || is_commit_sha ABCDEF0123456789abcdef0123456789abcdef01; then
  die "invalid commit SHA was accepted"
fi

log "Checking stable, prerelease and invalid version inputs"
for version in v1.2.3 v1.2.3-rc.1; do
  : >"$test_dir/output"
  VERSION="$version" GITHUB_OUTPUT="$test_dir/output" \
    bash "$REPO_DIR/scripts/release/validate-inputs.sh"
  assert_contains "$test_dir/output" "version=$version"
  channel=stable
  [[ "$version" != *-* ]] || channel=prerelease
  assert_contains "$test_dir/output" "channel=$channel"
done
for version in 1.2.3 v1.2 v1.2.3/invalid; do
  if VERSION="$version" bash "$REPO_DIR/scripts/release/validate-inputs.sh" >"$test_dir/error" 2>&1; then
    die "invalid version was accepted: $version"
  fi
done

log "Checking repository configuration"
export EIF_GITHUB_OWNER=example EIF_BACKEND_REPO=eif EIF_FRONTEND_REPO=eif-fe
export EIF_GHCR_IMAGE=ghcr.io/example/eif EIF_DOCKERHUB_IMAGE=example/eif
export EIF_GITHUB_APP_CLIENT_ID=test-only
bash "$REPO_DIR/scripts/release/validate-config.sh"
if EIF_FRONTEND_REPO=eif bash "$REPO_DIR/scripts/release/validate-config.sh" >"$test_dir/error" 2>&1; then
  die "duplicate repository names were accepted"
fi
if EIF_GHCR_IMAGE=ghcr.io/Example/eif bash "$REPO_DIR/scripts/release/validate-config.sh" >"$test_dir/error" 2>&1; then
  die "uppercase registry image was accepted"
fi

# These functions shadow external clients. No Docker/GitHub/network writes occur.
export EIF_TEST_COMMAND_LOG="$test_dir/commands"
docker() {
  printf '%s\n' "$*" >>"$EIF_TEST_COMMAND_LOG"
}
gh() {
  printf '%s\n' "$*" >>"$EIF_TEST_COMMAND_LOG"
}
export -f docker gh

log "Checking image tags without publishing"
for channel in stable prerelease; do
  : >"$EIF_TEST_COMMAND_LOG"
  EIF_VERSION=v1.2.3 EIF_CHANNEL="$channel" \
    bash "$REPO_DIR/scripts/release/publish-image.sh" eif:test
  assert_contains "$EIF_TEST_COMMAND_LOG" 'push ghcr.io/example/eif:v1.2.3'
  assert_contains "$EIF_TEST_COMMAND_LOG" 'push example/eif:v1.2.3'
  expected_pushes=2
  [[ "$channel" != stable ]] || expected_pushes=4
  [[ "$(grep -c '^push ' "$EIF_TEST_COMMAND_LOG")" == "$expected_pushes" ]] || die "wrong image tag count"
done

log "Checking GitHub Release arguments without publishing"
touch "$test_dir/release-notes.md"
for channel in stable prerelease; do
  : >"$EIF_TEST_COMMAND_LOG"
  EIF_VERSION=v1.2.3 EIF_CHANNEL="$channel" EIF_ORCHESTRATOR_SHA=test-only \
    GITHUB_REPOSITORY=example/eif-ci GH_TOKEN=test-only \
    bash "$REPO_DIR/scripts/release/publish-release.sh" "$test_dir"
  assert_contains "$EIF_TEST_COMMAND_LOG" 'release create v1.2.3 --repo example/eif-ci'
  if [[ "$channel" == prerelease ]]; then
    assert_contains "$EIF_TEST_COMMAND_LOG" '--prerelease'
  elif grep -F -- '--prerelease' "$EIF_TEST_COMMAND_LOG" >/dev/null; then
    die "stable release was marked prerelease"
  fi
done

GITHUB_STEP_SUMMARY="$test_dir/summary" VERSION=v1.2.3 \
  bash "$REPO_DIR/scripts/release/write-summary.sh"
assert_contains "$test_dir/summary" '| Version | `v1.2.3` |'
log "Release regression checks: OK (offline)"
