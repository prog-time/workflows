#!/usr/bin/env bats

load "../helpers/common"

SCRIPT="$BATS_TEST_DIRNAME/../../scripts/shell/linters/hadolint.sh"

setup() {
  setup_test_dir
}

teardown() {
  teardown_test_dir
}

@test "no Dockerfiles present: exits 0 and prints skipping messages" {
  mock_tool hadolint 0
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"⚠️ Dockerfile not found. Skipping."* ]]
  [[ "$output" == *"⚠️ docker/node/Dockerfile not found. Skipping."* ]]
  [[ "$output" == *"✅ All Dockerfiles passed Hadolint checks!"* ]]
}

@test "Dockerfile passes: exits 0 and prints success" {
  mock_tool hadolint 0
  touch Dockerfile
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"✅ All Dockerfiles passed Hadolint checks!"* ]]
}

@test "Dockerfile fails: exits 1 and prints failure message" {
  mkdir -p "$TEST_DIR/bin"
  cat > "$TEST_DIR/bin/hadolint" <<'EOF'
#!/usr/bin/env bash
echo "DL1234 some real error"
exit 1
EOF
  chmod +x "$TEST_DIR/bin/hadolint"
  export PATH="$TEST_DIR/bin:$PATH"

  touch Dockerfile
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"❌ Issues found in Dockerfile:"* ]]
  [[ "$output" == *"❌ Hadolint found issues in one or more Dockerfiles!"* ]]
}

@test "one of two Dockerfiles fails: exits 1 and checks both files" {
  mkdir -p "$TEST_DIR/bin" docker/node
  cat > "$TEST_DIR/bin/hadolint" <<'EOF'
#!/usr/bin/env bash
if [[ "$1" == "Dockerfile" ]]; then
  echo "DL1234 error in Dockerfile"
  exit 1
fi
exit 0
EOF
  chmod +x "$TEST_DIR/bin/hadolint"
  export PATH="$TEST_DIR/bin:$PATH"

  touch Dockerfile docker/node/Dockerfile
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"🔍 Checking Dockerfile"* ]]
  [[ "$output" == *"🔍 Checking docker/node/Dockerfile"* ]]
  [[ "$output" == *"❌ Hadolint found issues in one or more Dockerfiles!"* ]]
}
