#!/usr/bin/env bats

load "../helpers/common"

SCRIPT="$BATS_TEST_DIRNAME/../../scripts/shell/tests/cargo_test.sh"

setup() {
  setup_test_dir
  mkdir -p "$TEST_DIR/bin"
  export PATH="$TEST_DIR/bin:$PATH"
}

teardown() {
  teardown_test_dir
}

make_cargo_stub() {
  local exit_code="$1"
  cat > "$TEST_DIR/bin/cargo" <<EOF
#!/usr/bin/env bash
exit $exit_code
EOF
  chmod +x "$TEST_DIR/bin/cargo"
}

@test "no Cargo.toml: exits 1 with error annotation" {
  make_cargo_stub 0
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"::error::No Cargo.toml found"* ]]
}

@test "Cargo.toml present, tests pass: exits 0 with success message" {
  make_cargo_stub 0
  touch Cargo.toml
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"✅ cargo tests passed"* ]]
}

@test "Cargo.toml present, tests fail: exits 1 with failure message" {
  make_cargo_stub 1
  touch Cargo.toml
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"❌ cargo tests failed"* ]]
}
