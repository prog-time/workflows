#!/usr/bin/env bats

load "../helpers/common"

SCRIPT="$BATS_TEST_DIRNAME/../../scripts/shell/security/bundler-audit.sh"

setup() {
  setup_test_dir
  mkdir -p "$TEST_DIR/bin"
  export PATH="$TEST_DIR/bin:$PATH"
}

teardown() {
  teardown_test_dir
}

make_bundle_audit_stub() {
  local check_exit_code="$1"
  cat > "$TEST_DIR/bin/bundle-audit" <<EOF
#!/usr/bin/env bash
if [[ "\$1" == "check" ]]; then
  exit $check_exit_code
fi
# update and other subcommands succeed
exit 0
EOF
  chmod +x "$TEST_DIR/bin/bundle-audit"
}

@test "bundle-audit not installed: exits 1 with error annotation" {
  # Do not create a bundle-audit stub — it should be absent from PATH
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"::error::bundle-audit not found"* ]]
}

@test "no Gemfile.lock present: exits 1 with error annotation" {
  make_bundle_audit_stub 0
  cd "$TEST_DIR"
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"::error::No Gemfile.lock found"* ]]
}

@test "clean Gemfile.lock: exits 0 with success message" {
  make_bundle_audit_stub 0
  touch "$TEST_DIR/Gemfile.lock"
  cd "$TEST_DIR"
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"✅ bundler-audit passed"* ]]
}

@test "vulnerable gem in Gemfile.lock: exits 1 with failure message" {
  make_bundle_audit_stub 1
  touch "$TEST_DIR/Gemfile.lock"
  cd "$TEST_DIR"
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"❌ bundler-audit found vulnerabilities"* ]]
}
