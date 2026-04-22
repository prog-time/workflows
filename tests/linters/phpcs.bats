#!/usr/bin/env bats

load "../helpers/common"

SCRIPT="$BATS_TEST_DIRNAME/../../scripts/shell/linters/phpcs.sh"

setup() {
  setup_test_dir
  mkdir -p "$TEST_DIR/bin"
  export PATH="$TEST_DIR/bin:$PATH"
}

teardown() {
  teardown_test_dir
}

make_phpcs_stub() {
  local exit_code="$1"
  cat > "$TEST_DIR/bin/phpcs" <<EOF
#!/usr/bin/env bash
exit $exit_code
EOF
  chmod +x "$TEST_DIR/bin/phpcs"
}

@test "no ruleset found: exits 1 with error annotation" {
  make_phpcs_stub 0
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"::error::No phpcs ruleset found"* ]]
}

@test "phpcs.xml present, phpcs passes: exits 0 with success message" {
  make_phpcs_stub 0
  touch phpcs.xml
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"✅ phpcs passed"* ]]
}

@test "phpcs.xml present, phpcs reports violations: exits 1 with failure message" {
  make_phpcs_stub 1
  touch phpcs.xml
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"❌ phpcs found issues"* ]]
}
