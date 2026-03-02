#!/usr/bin/env bash
# Shared BATS helpers for linter tests

# Creates a temp dir, cd into it, saves path in $TEST_DIR
setup_test_dir() {
  TEST_DIR="$(mktemp -d)"
  cd "$TEST_DIR"
}

# Removes the temp dir
teardown_test_dir() {
  if [[ -n "${TEST_DIR:-}" && -d "$TEST_DIR" ]]; then
    rm -rf "$TEST_DIR"
  fi
}

# Creates a stub executable in $TEST_DIR/bin/ that always exits with <exit_code>
# Usage: mock_tool <name> <exit_code>
mock_tool() {
  local name="$1"
  local exit_code="$2"
  mkdir -p "$TEST_DIR/bin"
  cat > "$TEST_DIR/bin/$name" <<EOF
#!/usr/bin/env bash
exit $exit_code
EOF
  chmod +x "$TEST_DIR/bin/$name"
  export PATH="$TEST_DIR/bin:$PATH"
}

# Creates a stub that exits 1 only when its first argument matches a pattern
# The pattern is read from the env var MOCK_FAIL_PATTERN
# Usage: MOCK_FAIL_PATTERN="bad.html" mock_tool_conditional <name>
mock_tool_conditional() {
  local name="$1"
  mkdir -p "$TEST_DIR/bin"
  cat > "$TEST_DIR/bin/$name" <<'EOF'
#!/usr/bin/env bash
if [[ "${MOCK_FAIL_PATTERN:-}" != "" && "$1" == *"${MOCK_FAIL_PATTERN}"* ]]; then
  exit 1
fi
exit 0
EOF
  chmod +x "$TEST_DIR/bin/$name"
  export PATH="$TEST_DIR/bin:$PATH"
}
