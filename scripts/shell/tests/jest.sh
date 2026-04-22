#!/usr/bin/env bash
set -euo pipefail

CONFIG_FOUND=0

if [ -f "package.json" ]; then
  if grep -q '"jest"' package.json; then
    CONFIG_FOUND=1
  fi
  for config in "jest.config.js" "jest.config.ts" "jest.config.mjs" "jest.config.cjs"; do
    if [ -f "$config" ]; then
      CONFIG_FOUND=1
      break
    fi
  done
fi

if [ $CONFIG_FOUND -eq 0 ]; then
  echo "::error::No Jest configuration found"
  exit 1
fi

if npx jest --ci --runInBand --passWithNoTests; then
  echo "✅ Jest tests passed"
else
  echo "❌ Jest tests failed"
  exit 1
fi
