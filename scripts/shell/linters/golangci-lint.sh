#!/usr/bin/env bash
set -euo pipefail

go_files=$(find . -type f -name "*.go" \
  -not -path "./.git/*" \
  -not -path "./vendor/*")

if [ -z "$go_files" ]; then
  echo "⚠️ No .go files found. Skipping."
  exit 0
fi

echo "ℹ️ Running golangci-lint..."
golangci-lint run ./...
echo "✅ All Go files passed golangci-lint checks!"
