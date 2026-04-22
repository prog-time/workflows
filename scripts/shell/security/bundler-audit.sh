#!/usr/bin/env bash
set -euo pipefail

if ! command -v bundle-audit &> /dev/null; then
  echo "::error::bundle-audit not found. Install it before running this script."
  exit 1
fi

if [[ ! -f "Gemfile.lock" ]]; then
  echo "::error::No Gemfile.lock found. Run 'bundle install' to generate one."
  exit 1
fi

echo "ℹ️ Running bundle-audit..."

bundle-audit update
if bundle-audit check; then
  echo "✅ bundler-audit passed"
else
  echo "❌ bundler-audit found vulnerabilities"
  exit 1
fi
