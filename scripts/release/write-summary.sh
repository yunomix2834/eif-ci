#!/usr/bin/env bash
set -euo pipefail

{
  printf '## EIF Release\n\n'
  printf '| Field | Value |\n|---|---|\n'
  printf '| Version | `%s` |\n' "${VERSION:-}"
  printf '| Backend | `%s` |\n' "${BACKEND_SHA:-}"
  printf '| Frontend | `%s` |\n' "${FRONTEND_SHA:-}"
  printf '| Windows | `EIF-Windows-x64.zip` |\n'
  printf '| Linux | `eif-linux-amd64` |\n'
} >>"${GITHUB_STEP_SUMMARY:?GITHUB_STEP_SUMMARY is required}"
