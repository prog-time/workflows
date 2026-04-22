#!/usr/bin/env bats

load "../helpers/common"

SCRIPT="$BATS_TEST_DIRNAME/../../scripts/shell/security/trivy.sh"

setup() {
  setup_test_dir
  mkdir -p "$TEST_DIR/bin"
  export PATH="$TEST_DIR/bin:$PATH"
}

teardown() {
  teardown_test_dir
}

make_trivy_stub() {
  local exit_code="$1"
  cat > "$TEST_DIR/bin/trivy" <<EOF
#!/usr/bin/env bash
exit $exit_code
EOF
  chmod +x "$TEST_DIR/bin/trivy"
}

@test "trivy not installed: exits 1 with error annotation" {
  # Do not create a trivy stub — it should be absent from PATH
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"::error::trivy not found"* ]]
}

@test "trivy finds no vulnerabilities: exits 0 with success message" {
  make_trivy_stub 0
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"✅ No HIGH/CRITICAL vulnerabilities"* ]]
}

@test "trivy finds vulnerabilities: exits 1 with failure message" {
  make_trivy_stub 1
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"❌ Trivy found HIGH/CRITICAL vulnerabilities"* ]]
}

@test "scan message is printed before running trivy" {
  make_trivy_stub 0
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"ℹ️ Running Trivy filesystem scan"* ]]
}
