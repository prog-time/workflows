#!/usr/bin/env bats

load "../helpers/common"

SCRIPT="$BATS_TEST_DIRNAME/../../scripts/shell/linters/tflint.sh"

setup() {
  setup_test_dir
  mkdir -p "$TEST_DIR/bin"
  export PATH="$TEST_DIR/bin:$PATH"
}

teardown() {
  teardown_test_dir
}

make_tflint_stub() {
  local exit_code="$1"
  cat > "$TEST_DIR/bin/tflint" <<EOF
#!/usr/bin/env bash
# --init always succeeds; --recursive exits with the configured code
for arg in "\$@"; do
  if [[ "\$arg" == "--recursive" ]]; then
    exit $exit_code
  fi
done
exit 0
EOF
  chmod +x "$TEST_DIR/bin/tflint"
}

@test "no Terraform files: exits 0 with skip message" {
  make_tflint_stub 0
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"⚠️ No Terraform files found. Skipping."* ]]
}

@test "Terraform files present, tflint passes: exits 0 with success message" {
  make_tflint_stub 0
  touch main.tf
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"✅ tflint passed"* ]]
}

@test "Terraform files present, tflint finds issues: exits 1 with failure message" {
  make_tflint_stub 1
  touch main.tf
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"❌ tflint found issues"* ]]
}
