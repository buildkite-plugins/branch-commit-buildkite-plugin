#!/usr/bin/env bats

setup() {
  load "${BATS_PLUGIN_PATH}/load.bash"

  export BUILDKITE_SOURCE="ui"
  export BUILDKITE_BRANCH="main"
  export BUILDKITE_COMMIT="abc123"
  export BUILDKITE_PLUGIN_BRANCH_COMMIT_MODE="warn"
}

@test "Non-UI source exits immediately" {
  export BUILDKITE_SOURCE="webhook"

  run "$PWD"/hooks/post-checkout

  assert_success
  assert_output ""
}

@test "Missing BUILDKITE_BRANCH fails with error" {
  unset BUILDKITE_BRANCH

  run "$PWD"/hooks/post-checkout

  assert_failure
  assert_output --partial "ERROR: BUILDKITE_BRANCH environment variable is not set."
}

@test "Missing BUILDKITE_COMMIT fails with error" {
  unset BUILDKITE_COMMIT

  run "$PWD"/hooks/post-checkout

  assert_failure
  assert_output --partial "ERROR: BUILDKITE_COMMIT environment variable is not set."
}

@test "Matching branch succeeds" {
  stub git \
    "rev-parse abc123 : echo abc123" \
    "name-rev --name-only abc123 : echo main"

  run "$PWD"/hooks/post-checkout

  assert_success
  assert_output ""

  unstub git
}

@test "Branch mismatch in warn mode prints warning" {
  stub git \
    "rev-parse abc123 : echo abc123" \
    "name-rev --name-only abc123 : echo develop"

  run "$PWD"/hooks/post-checkout

  assert_success
  assert_output --partial "WARNING: Commit branch (develop) does not match BUILDKITE_BRANCH (main)."

  unstub git
}

@test "Branch mismatch in strict mode fails with error" {
  export BUILDKITE_PLUGIN_BRANCH_COMMIT_MODE="strict"

  stub git \
    "rev-parse abc123 : echo abc123" \
    "name-rev --name-only abc123 : echo develop"

  run "$PWD"/hooks/post-checkout

  assert_failure
  assert_output --partial "ERROR: Commit branch (develop) does not match BUILDKITE_BRANCH (main)."

  unstub git
}

@test "Matching branch in strict mode succeeds" {
  export BUILDKITE_PLUGIN_BRANCH_COMMIT_MODE="strict"

  stub git \
    "rev-parse abc123 : echo abc123" \
    "name-rev --name-only abc123 : echo main"

  run "$PWD"/hooks/post-checkout

  assert_success
  assert_output ""

  unstub git
}
