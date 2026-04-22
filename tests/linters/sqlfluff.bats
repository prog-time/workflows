#!/usr/bin/env bats

load "../helpers/common"

SCRIPT="$BATS_TEST_DIRNAME/../../scripts/shell/linters/sqlfluff.sh"

setup() {
  setup_test_dir
  mkdir -p "$TEST_DIR/bin"
  export PATH="$TEST_DIR/bin:$PATH"
}

teardown() {
  teardown_test_dir
}

make_sqlfluff_stub() {
  local exit_code="$1"
  cat > "$TEST_DIR/bin/sqlfluff" <<EOF
#!/usr/bin/env bash
exit $exit_code
EOF
  chmod +x "$TEST_DIR/bin/sqlfluff"
}

@test "no config found: exits 1 with error annotation" {
  make_sqlfluff_stub 0
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"::error::No SQLFluff config found"* ]]
}

@test "config present, no SQL files: exits 0 with skip message" {
  make_sqlfluff_stub 0
  touch .sqlfluff
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"⚠️ No SQL files found. Skipping."* ]]
}

@test "config present, SQL files pass: exits 0 with success message" {
  make_sqlfluff_stub 0
  touch .sqlfluff migration.sql
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"✅ SQLFluff passed"* ]]
}

@test "config present, SQL files fail: exits 1 with failure message" {
  make_sqlfluff_stub 1
  touch .sqlfluff migration.sql
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"❌ SQLFluff found issues"* ]]
}
