#!/usr/bin/env bats

load "../helpers/common"

SCRIPT="$BATS_TEST_DIRNAME/../../scripts/shell/tests/xcodebuild_test.sh"

setup() {
  setup_test_dir
  mkdir -p "$TEST_DIR/bin"
  export PATH="$TEST_DIR/bin:$PATH"

  # Stub xcodebuild and xcpretty so the guards pass in structural tests
  cat > "$TEST_DIR/bin/xcodebuild" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
  chmod +x "$TEST_DIR/bin/xcodebuild"

  cat > "$TEST_DIR/bin/xcpretty" <<'EOF'
#!/usr/bin/env bash
cat
EOF
  chmod +x "$TEST_DIR/bin/xcpretty"
}

teardown() {
  teardown_test_dir
}

@test "no workspace or project: exits 1 with no-project error" {
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"::error::No Xcode workspace or project found"* ]]
}

@test "two workspaces present: exits 1 with disambiguation error" {
  mkdir -p "App.xcworkspace" "Other.xcworkspace"
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"::error::Multiple Xcode workspaces/projects found"* ]]
}
