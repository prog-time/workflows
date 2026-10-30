#!/usr/bin/env bats

load "../helpers/common"

SCRIPT="$BATS_TEST_DIRNAME/../../scripts/shell/linters/pint.sh"

setup() {
  setup_test_dir
}

teardown() {
  teardown_test_dir
}

make_pint_stub() {
  local exit_code="$1"
  mkdir -p "$TEST_DIR/vendor/bin"
  cat > "$TEST_DIR/vendor/bin/pint" <<STUB
#!/usr/bin/env bash
exit $exit_code
STUB
  chmod +x "$TEST_DIR/vendor/bin/pint"
}

@test "pint not installed: exits 1 with error annotation" {
  PATH="/usr/bin:/bin" run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"::error::laravel/pint not found"* ]]
}

@test "clean code: exits 0 with success message" {
  make_pint_stub 0
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"✅ pint passed"* ]]
}

@test "style issues: exits 1 with failure message" {
  make_pint_stub 1
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"❌ pint found style issues"* ]]
}
