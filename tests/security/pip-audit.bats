#!/usr/bin/env bats

load "../helpers/common"

SCRIPT="$BATS_TEST_DIRNAME/../../scripts/shell/security/pip-audit.sh"

setup() {
  setup_test_dir
  mkdir -p "$TEST_DIR/bin"
  export PATH="$TEST_DIR/bin:$PATH"
}

teardown() {
  teardown_test_dir
}

make_pip_audit_stub() {
  local exit_code="$1"
  cat > "$TEST_DIR/bin/pip-audit" <<EOF
#!/usr/bin/env bash
exit $exit_code
EOF
  chmod +x "$TEST_DIR/bin/pip-audit"
}

@test "pip-audit not installed: exits 1 with error annotation" {
  # Do not create a pip-audit stub — it should be absent from PATH
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"::error::pip-audit not found"* ]]
}

@test "no requirements file present: exits 1 with error annotation" {
  make_pip_audit_stub 0
  cd "$TEST_DIR"
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"::error::No Python requirements file found"* ]]
}

@test "clean requirements.txt: exits 0 with success message" {
  make_pip_audit_stub 0
  echo "requests==2.31.0" > "$TEST_DIR/requirements.txt"
  cd "$TEST_DIR"
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"✅ pip-audit passed"* ]]
}

@test "vulnerable pin in requirements.txt: exits 1 with failure message" {
  make_pip_audit_stub 1
  echo "django==2.2.0" > "$TEST_DIR/requirements.txt"
  cd "$TEST_DIR"
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" != *"✅ pip-audit passed"* ]]
}
