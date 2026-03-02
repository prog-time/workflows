#!/usr/bin/env bats

load "../helpers/common"

SCRIPT="$BATS_TEST_DIRNAME/../../scripts/shell/linters/yamllint.sh"

setup() {
  setup_test_dir
  mkdir -p "$TEST_DIR/bin"
  export PATH="$TEST_DIR/bin:$PATH"
}

teardown() {
  teardown_test_dir
}

make_yamllint_stub() {
  local exit_code="$1"
  cat > "$TEST_DIR/bin/yamllint" <<EOF
#!/usr/bin/env bash
exit $exit_code
EOF
  chmod +x "$TEST_DIR/bin/yamllint"
}

make_yamllint_conditional_stub() {
  cat > "$TEST_DIR/bin/yamllint" <<'EOF'
#!/usr/bin/env bash
if [[ "${MOCK_FAIL_PATTERN:-}" != "" && "$1" == *"${MOCK_FAIL_PATTERN}"* ]]; then
  exit 1
fi
exit 0
EOF
  chmod +x "$TEST_DIR/bin/yamllint"
}

@test "config file missing: exits 1 with ::error:: message" {
  make_yamllint_stub 0
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"::error::Config file .yamllint.yml not found"* ]]
}

@test "no YAML files found: exits 0 with skipping message" {
  make_yamllint_stub 0
  touch .yamllint.yml
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"⚠️ No YAML files found. Skipping."* ]]
}

@test "all files pass: exits 0 with success message" {
  make_yamllint_stub 0
  touch .yamllint.yml config.yml docker-compose.yaml
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"✅ All YAML files passed yamllint checks!"* ]]
}

@test "one file fails: exits 1 with failure message" {
  make_yamllint_stub 1
  touch .yamllint.yml config.yml
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"❌ yamllint found issues!"* ]]
}

@test "multiple files, one fails: exits 1 and all files are checked" {
  make_yamllint_conditional_stub
  touch .yamllint.yml good.yml bad.yml
  MOCK_FAIL_PATTERN="bad.yml" run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"ℹ️ Checking good.yml"* ]]
  [[ "$output" == *"ℹ️ Checking bad.yml"* ]]
  [[ "$output" == *"❌ yamllint found issues!"* ]]
}
