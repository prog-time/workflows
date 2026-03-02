#!/usr/bin/env bats

load "../helpers/common"

SCRIPT="$BATS_TEST_DIRNAME/../../scripts/shell/linters/markdownlint.sh"

setup() {
  setup_test_dir
  mkdir -p "$TEST_DIR/bin"
  export PATH="$TEST_DIR/bin:$PATH"
}

teardown() {
  teardown_test_dir
}

make_markdownlint_stub() {
  local exit_code="$1"
  cat > "$TEST_DIR/bin/markdownlint" <<EOF
#!/usr/bin/env bash
exit $exit_code
EOF
  chmod +x "$TEST_DIR/bin/markdownlint"
}

make_markdownlint_conditional_stub() {
  cat > "$TEST_DIR/bin/markdownlint" <<'EOF'
#!/usr/bin/env bash
if [[ "${MOCK_FAIL_PATTERN:-}" != "" && "$1" == *"${MOCK_FAIL_PATTERN}"* ]]; then
  exit 1
fi
exit 0
EOF
  chmod +x "$TEST_DIR/bin/markdownlint"
}

@test "config file missing: exits 1 with ::error:: message" {
  make_markdownlint_stub 0
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"::error::Config file .markdownlint.yml not found"* ]]
}

@test "no .md files found: exits 0 with skipping message" {
  make_markdownlint_stub 0
  touch .markdownlint.yml
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"⚠️ No .md files found. Skipping."* ]]
}

@test "all files pass: exits 0 with success message" {
  make_markdownlint_stub 0
  touch .markdownlint.yml README.md CONTRIBUTING.md
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"✅ All markdown files passed markdownlint checks!"* ]]
}

@test "one file fails: exits 1 with failure message" {
  make_markdownlint_stub 1
  touch .markdownlint.yml README.md
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"❌ markdownlint found issues!"* ]]
}

@test "multiple files, one fails: exits 1 and all files are checked" {
  make_markdownlint_conditional_stub
  touch .markdownlint.yml good.md bad.md
  MOCK_FAIL_PATTERN="bad.md" run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"ℹ️ Checking good.md"* ]]
  [[ "$output" == *"ℹ️ Checking bad.md"* ]]
  [[ "$output" == *"❌ markdownlint found issues!"* ]]
}
