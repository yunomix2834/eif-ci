#!/usr/bin/env bash
set -euo pipefail

log() {
  printf '[eif-ci] %s\n' "$*"
}

die() {
  printf '[eif-ci] ERROR: %s\n' "$*" >&2
  exit 1
}

require_cmd() {
  local name
  for name in "$@"; do
    command -v "$name" >/dev/null 2>&1 || die "required command not found: $name"
  done
}

require_env() {
  local name
  for name in "$@"; do
    [[ -n "${!name:-}" ]] || die "$name is required"
  done
}

is_commit_sha() {
  [[ "$1" =~ ^[0-9a-f]{40}$ ]]
}

encode_uri_component() {
  jq -rn --arg value "$1" '$value | @uri'
}

write_output() {
  local key=$1
  local value=$2
  if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
    printf '%s=%s\n' "$key" "$value" >>"$GITHUB_OUTPUT"
  fi
}
