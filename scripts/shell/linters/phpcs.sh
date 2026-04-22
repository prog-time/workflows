#!/usr/bin/env bash
set -euo pipefail

CONFIG_FOUND=0
for cfg in phpcs.xml phpcs.xml.dist .phpcs.xml .phpcs.xml.dist; do
  if [[ -f "$cfg" ]]; then
    CONFIG_FOUND=1
    break
  fi
done

if [[ $CONFIG_FOUND -eq 0 ]]; then
  echo "::error::No phpcs ruleset found (expected phpcs.xml, phpcs.xml.dist, .phpcs.xml, or .phpcs.xml.dist)"
  exit 1
fi

if [[ -x "vendor/bin/phpcs" ]]; then
  PHPCS="vendor/bin/phpcs"
else
  PHPCS="phpcs"
fi

if "$PHPCS"; then
  echo "✅ phpcs passed"
else
  echo "❌ phpcs found issues"
  exit 1
fi
