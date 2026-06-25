#!/usr/bin/env bash
set -euo pipefail

if ! command -v composer &> /dev/null; then
  echo "::error::composer not found. Install it before running this script."
  exit 1
fi

if [[ ! -f "composer.lock" ]]; then
  echo "::error::No composer.lock found. Run 'composer install' to generate one."
  exit 1
fi

echo "ℹ️ Running composer audit..."

if composer audit --abandoned=ignore; then
  echo "✅ composer-audit passed"
else
  echo "❌ composer-audit found vulnerabilities"
  exit 1
fi
