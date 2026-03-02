#!/usr/bin/env bats

load "../helpers/common"

SCRIPT="$BATS_TEST_DIRNAME/../../scripts/shell/linters/htmlhint.sh"

setup() {
  setup_test_dir
  # mock npx so it dispatches to our stub
  mkdir -p "$TEST_DIR/bin"
  export PATH="$TEST_DIR/bin:$PATH"
}

teardown() {
  teardown_test_dir
}

# Helper: create a stub for "npx htmlhint" via a wrapper named "npx"
make_npx_stub() {
  local exit_code="$1"
  cat > "$TEST_DIR/bin/npx" <<EOF
#!/usr/bin/env bash
# argv[0]=htmlhint argv[1]=<file>
exit $exit_code
EOF
  chmod +x "$TEST_DIR/bin/npx"
}

make_npx_conditional_stub() {
  cat > "$TEST_DIR/bin/npx" <<'EOF'
#!/usr/bin/env bash
# $1 = htmlhint, $2 = file
if [[ "${MOCK_FAIL_PATTERN:-}" != "" && "$2" == *"${MOCK_FAIL_PATTERN}"* ]]; then
  exit 1
fi
exit 0
EOF
  chmod +x "$TEST_DIR/bin/npx"
}

@test "config file missing: exits 1 with ::error:: message" {
  make_npx_stub 0
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"::error::Config file .htmlhintrc not found"* ]]
}

@test "no HTML files found: exits 0 with skipping message" {
  make_npx_stub 0
  touch .htmlhintrc
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"⚠️ No .html files found. Skipping."* ]]
}

@test "all files pass: exits 0 with success message" {
  make_npx_stub 0
  touch .htmlhintrc index.html about.html
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"✅ All HTML files passed htmlhint checks!"* ]]
}

@test "one file fails: exits 1 with failure message" {
  make_npx_stub 1
  touch .htmlhintrc index.html
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"❌ htmlhint found issues!"* ]]
}

@test "multiple files, one fails: exits 1 and all files are checked" {
  make_npx_conditional_stub
  touch .htmlhintrc good.html bad.html
  MOCK_FAIL_PATTERN="bad.html" run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"ℹ️ Checking good.html"* ]]
  [[ "$output" == *"ℹ️ Checking bad.html"* ]]
  [[ "$output" == *"❌ htmlhint found issues!"* ]]
}
