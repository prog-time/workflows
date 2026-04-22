#!/usr/bin/env bash
set -euo pipefail

if ! command -v tflint > /dev/null 2>&1; then
  echo "::error::tflint is not installed or not in PATH"
  exit 1
fi

TF_COUNT=$(find . -type f -name "*.tf" \
  -not -path "./.git/*" \
  -not -path "./.terraform/*" | wc -l | tr -d ' ')

if [[ "$TF_COUNT" -eq 0 ]]; then
  echo "⚠️ No Terraform files found. Skipping."
  exit 0
fi

tflint --init

if tflint --recursive; then
  echo "✅ tflint passed"
else
  echo "❌ tflint found issues"
  exit 1
fi
