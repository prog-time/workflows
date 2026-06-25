#!/usr/bin/env bash
set -euo pipefail

if [[ -x "vendor/bin/pint" ]]; then
  PINT="vendor/bin/pint"
elif command -v pint &> /dev/null; then
  PINT="pint"
else
  echo "::error::laravel/pint not found (run 'composer require --dev laravel/pint')"
  exit 1
fi

echo "ℹ️ Running Pint in check mode..."

if "$PINT" --test; then
  echo "✅ pint passed"
else
  echo "❌ pint found style issues"
  exit 1
fi
