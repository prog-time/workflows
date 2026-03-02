#!/usr/bin/env bats

load "helpers/common"

ASSEMBLER="$BATS_TEST_DIRNAME/../scripts/assemble-ci.sh"

setup() {
  setup_test_dir
  mkdir -p scripts/CI/linters scripts/shell/linters CI/linters

  cat > scripts/CI/linters/foo.yml <<'EOF'
foo:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4

    - name: Run foo
      run: bash scripts/shell/linters/foo.sh
EOF

  cat > scripts/shell/linters/foo.sh <<'EOF'
#!/usr/bin/env bash
echo "hello from foo"
EOF
}

teardown() {
  teardown_test_dir
}

@test "run line is replaced with 'run: |' and script body inlined" {
  run bash "$ASSEMBLER" scripts/CI/linters scripts/shell/linters CI/linters
  [ "$status" -eq 0 ]
  grep -q 'run: |' CI/linters/foo.yml
  grep -q 'echo "hello from foo"' CI/linters/foo.yml
}

@test "missing script: dist YAML is identical to source" {
  rm scripts/shell/linters/foo.sh
  run bash "$ASSEMBLER" scripts/CI/linters scripts/shell/linters CI/linters
  [ "$status" -eq 0 ]
  diff scripts/CI/linters/foo.yml CI/linters/foo.yml
}

@test "shebang is stripped from inlined script" {
  run bash "$ASSEMBLER" scripts/CI/linters scripts/shell/linters CI/linters
  [ "$status" -eq 0 ]
  run grep -q '#!/usr/bin/env bash' CI/linters/foo.yml
  [ "$status" -ne 0 ]
}

@test "non-run lines are preserved verbatim" {
  run bash "$ASSEMBLER" scripts/CI/linters scripts/shell/linters CI/linters
  [ "$status" -eq 0 ]
  grep -q 'uses: actions/checkout@v4' CI/linters/foo.yml
}
