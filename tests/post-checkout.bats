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

@test "Commit is on branch in shallow repo succeeds" {
  stub git \
    "rev-parse --is-shallow-repository : echo true" \
    "fetch --unshallow origin main : " \
    "merge-base --is-ancestor abc123 origin/main : "

  run "$PWD"/hooks/post-checkout

  assert_success
  assert_output ""

  unstub git
}

@test "Commit is on branch in non-shallow repo succeeds" {
  stub git \
    "rev-parse --is-shallow-repository : echo false" \
    "fetch origin main : " \
    "merge-base --is-ancestor abc123 origin/main : "

  run "$PWD"/hooks/post-checkout

  assert_success
  assert_output ""

  unstub git
}

@test "Branch mismatch in warn mode prints warning" {
  stub git \
    "rev-parse --is-shallow-repository : echo true" \
    "fetch --unshallow origin main : " \
    "merge-base --is-ancestor abc123 origin/main : exit 1"

  run "$PWD"/hooks/post-checkout

  assert_success
  assert_output --partial "WARNING: Commit abc123 is not on branch main."

  unstub git
}

@test "Branch mismatch in strict mode fails with error" {
  export BUILDKITE_PLUGIN_BRANCH_COMMIT_MODE="strict"

  stub git \
    "rev-parse --is-shallow-repository : echo true" \
    "fetch --unshallow origin main : " \
    "merge-base --is-ancestor abc123 origin/main : exit 1"

  run "$PWD"/hooks/post-checkout

  assert_failure
  assert_output --partial "ERROR: Commit abc123 is not on branch main."

  unstub git
}

@test "Fetch failure in warn mode prints warning" {
  stub git \
    "rev-parse --is-shallow-repository : echo false" \
    "fetch origin main : exit 128"

  run "$PWD"/hooks/post-checkout

  assert_success
  assert_output --partial "WARNING: Commit abc123 is not on branch main."

  unstub git
}

@test "Fetch failure in strict mode fails with error" {
  export BUILDKITE_PLUGIN_BRANCH_COMMIT_MODE="strict"

  stub git \
    "rev-parse --is-shallow-repository : echo false" \
    "fetch origin main : exit 128"

  run "$PWD"/hooks/post-checkout

  assert_failure
  assert_output --partial "ERROR: Commit abc123 is not on branch main."

  unstub git
}

@test "Matching branch in strict mode succeeds" {
  export BUILDKITE_PLUGIN_BRANCH_COMMIT_MODE="strict"

  stub git \
    "rev-parse --is-shallow-repository : echo true" \
    "fetch --unshallow origin main : " \
    "merge-base --is-ancestor abc123 origin/main : "

  run "$PWD"/hooks/post-checkout

  assert_success
  assert_output ""

  unstub git
}
