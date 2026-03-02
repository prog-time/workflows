#!/usr/bin/env bats

load "../helpers/common"

SCRIPT="$BATS_TEST_DIRNAME/../../scripts/shell/linters/shellcheck.sh"

setup() {
  setup_test_dir
  mkdir -p "$TEST_DIR/bin"
  export PATH="$TEST_DIR/bin:$PATH"
}

teardown() {
  teardown_test_dir
}

make_shellcheck_stub() {
  local exit_code="$1"
  cat > "$TEST_DIR/bin/shellcheck" <<EOF
#!/usr/bin/env bash
exit $exit_code
EOF
  chmod +x "$TEST_DIR/bin/shellcheck"
}

make_shellcheck_conditional_stub() {
  cat > "$TEST_DIR/bin/shellcheck" <<'EOF'
#!/usr/bin/env bash
# $1 = --severity=warning, $2 = file
if [[ "${MOCK_FAIL_PATTERN:-}" != "" && "$2" == *"${MOCK_FAIL_PATTERN}"* ]]; then
  exit 1
fi
exit 0
EOF
  chmod +x "$TEST_DIR/bin/shellcheck"
}

@test "directories don't exist: exits 0 with skipping messages" {
  make_shellcheck_stub 0
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"⚠️ Directory scripts does not exist. Skipping."* ]]
  [[ "$output" == *"⚠️ Directory docker/scripts does not exist. Skipping."* ]]
  [[ "$output" == *"✅ All shell scripts passed important ShellCheck checks!"* ]]
}

@test "directory exists but no .sh files: exits 0 with no-files message" {
  make_shellcheck_stub 0
  mkdir -p scripts
  touch scripts/not_a_script.txt
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"No .sh files found in scripts"* ]]
  [[ "$output" == *"✅ All shell scripts passed important ShellCheck checks!"* ]]
}

@test "all scripts pass: exits 0 with success message" {
  make_shellcheck_stub 0
  mkdir -p scripts
  touch scripts/deploy.sh scripts/build.sh
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"✅ All shell scripts passed important ShellCheck checks!"* ]]
}

@test "one script fails: exits 1 with failure message" {
  make_shellcheck_stub 1
  mkdir -p scripts
  touch scripts/bad.sh
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"❌ ShellCheck found important issues!"* ]]
}
