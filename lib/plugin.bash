#!/bin/bash
set -euo pipefail

PLUGIN_PREFIX="BRANCH_COMMIT"

# Usage: mode=$(plugin_read_config MODE "strict")
function plugin_read_config() {
  local var="BUILDKITE_PLUGIN_${PLUGIN_PREFIX}_${1}"
  local default="${2:-}"
  echo "${!var:-$default}"
}
