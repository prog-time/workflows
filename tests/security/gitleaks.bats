#!/usr/bin/env bats

load "../helpers/common"

SCRIPT="$BATS_TEST_DIRNAME/../../scripts/shell/security/gitleaks.sh"

setup() {
  setup_test_dir
  mkdir -p "$TEST_DIR/bin"
  export PATH="$TEST_DIR/bin:$PATH"
}

teardown() {
  teardown_test_dir
}

make_gitleaks_stub() {
  local exit_code="$1"
  cat > "$TEST_DIR/bin/gitleaks" <<EOF
#!/usr/bin/env bash
exit $exit_code
EOF
  chmod +x "$TEST_DIR/bin/gitleaks"
}

@test "gitleaks not installed: exits 1 with error annotation" {
  # Do not create a gitleaks stub — it should be absent from PATH
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"::error::gitleaks not found"* ]]
}

@test "gitleaks finds no secrets: exits 0 with success message" {
  make_gitleaks_stub 0
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"No secrets found"* ]]
}

@test "gitleaks finds secrets: exits 1 with failure message" {
  make_gitleaks_stub 1
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"gitleaks found potential secrets"* ]]
}

@test "scan message is printed before running gitleaks" {
  make_gitleaks_stub 0
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"ℹ️ Running gitleaks on the repository"* ]]
}
