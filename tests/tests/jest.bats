#!/usr/bin/env bats

load "../helpers/common"

SCRIPT="$BATS_TEST_DIRNAME/../../scripts/shell/tests/jest.sh"

setup() {
  setup_test_dir
  mkdir -p "$TEST_DIR/bin"
  export PATH="$TEST_DIR/bin:$PATH"
}

teardown() {
  teardown_test_dir
}

# Helper: create a stub for "npx jest ..." that always exits with <exit_code>
make_npx_stub() {
  local exit_code="$1"
  cat > "$TEST_DIR/bin/npx" <<EOF
#!/usr/bin/env bash
exit $exit_code
EOF
  chmod +x "$TEST_DIR/bin/npx"
}

@test "no jest config: exits 1 with ::error:: message" {
  make_npx_stub 0
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"::error::No Jest configuration found"* ]]
}

@test "package.json with jest in devDependencies, tests pass: exits 0 with success message" {
  make_npx_stub 0
  cat > package.json <<'EOF'
{
  "devDependencies": {
    "jest": "^29.0.0"
  }
}
EOF
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"✅ Jest tests passed"* ]]
}

@test "jest.config.js present (no jest in devDependencies), tests fail: exits 1 with failure message" {
  make_npx_stub 1
  cat > package.json <<'EOF'
{
  "devDependencies": {}
}
EOF
  touch jest.config.js
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"❌ Jest tests failed"* ]]
}
