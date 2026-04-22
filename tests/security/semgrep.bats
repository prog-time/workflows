#!/usr/bin/env bats

load "../helpers/common"

SCRIPT="$BATS_TEST_DIRNAME/../../scripts/shell/security/semgrep.sh"

setup() {
  setup_test_dir
  mkdir -p "$TEST_DIR/bin"
  export PATH="$TEST_DIR/bin:$PATH"
}

teardown() {
  teardown_test_dir
}

make_semgrep_stub() {
  local exit_code="$1"
  cat > "$TEST_DIR/bin/semgrep" <<EOF
#!/usr/bin/env bash
exit $exit_code
EOF
  chmod +x "$TEST_DIR/bin/semgrep"
}

@test "semgrep not installed: exits 1 with error annotation" {
  # Do not create a semgrep stub — it should be absent from PATH
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"::error::semgrep not found"* ]]
}

@test "semgrep finds no issues: exits 0 with success message" {
  make_semgrep_stub 0
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"✅ Semgrep passed"* ]]
}

@test "semgrep finds issues: exits 1 with failure message" {
  make_semgrep_stub 1
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"❌ Semgrep found issues"* ]]
}

@test "scan message is printed before running semgrep" {
  make_semgrep_stub 0
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"ℹ️ Running Semgrep static analysis"* ]]
}
