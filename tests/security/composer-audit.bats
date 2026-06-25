#!/usr/bin/env bats

load "../helpers/common"

SCRIPT="$BATS_TEST_DIRNAME/../../scripts/shell/security/composer-audit.sh"

setup() {
  setup_test_dir
}

teardown() {
  teardown_test_dir
}

make_composer_stub() {
  local audit_exit_code="$1"
  mkdir -p "$TEST_DIR/bin"
  cat > "$TEST_DIR/bin/composer" <<STUB
#!/usr/bin/env bash
if [[ "\$1" == "audit" ]]; then
  exit $audit_exit_code
fi
exit 0
STUB
  chmod +x "$TEST_DIR/bin/composer"
  export PATH="$TEST_DIR/bin:$PATH"
}

@test "composer not installed: exits 1 with error annotation" {
  PATH="/usr/bin:/bin" run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"::error::composer not found"* ]]
}

@test "no composer.lock present: exits 1 with error annotation" {
  make_composer_stub 0
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"::error::No composer.lock found"* ]]
}

@test "clean composer.lock: exits 0 with success message" {
  make_composer_stub 0
  touch "$TEST_DIR/composer.lock"
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"✅ composer-audit passed"* ]]
}

@test "vulnerable dependency: exits 1 with failure message" {
  make_composer_stub 1
  touch "$TEST_DIR/composer.lock"
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"❌ composer-audit found vulnerabilities"* ]]
}
