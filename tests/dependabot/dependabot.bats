#!/usr/bin/env bats

TEMPLATE="$BATS_TEST_DIRNAME/../../dependabot/dependabot.yml"

@test "file parses as valid YAML" {
  run yamllint "$TEMPLATE"
  [ "$status" -eq 0 ]
}

@test "version is 2" {
  grep -q "^version: 2$" "$TEMPLATE"
}

@test "all required ecosystems are present" {
  grep -q "package-ecosystem: \"github-actions\"" "$TEMPLATE"
  grep -q "package-ecosystem: \"npm\""            "$TEMPLATE"
  grep -q "package-ecosystem: \"pip\""            "$TEMPLATE"
  grep -q "package-ecosystem: \"bundler\""        "$TEMPLATE"
  grep -q "package-ecosystem: \"composer\""       "$TEMPLATE"
  grep -q "package-ecosystem: \"cargo\""          "$TEMPLATE"
  grep -q "package-ecosystem: \"gomod\""          "$TEMPLATE"
}

@test "every entry has schedule.interval set" {
  ecosystem_count=$(grep -c "package-ecosystem:" "$TEMPLATE")
  interval_count=$(grep -c "interval:" "$TEMPLATE")
  [ "$interval_count" -eq "$ecosystem_count" ]
}
