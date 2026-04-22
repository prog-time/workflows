#!/usr/bin/env bash
set -euo pipefail

if ! command -v semgrep &> /dev/null; then
  echo "::error::semgrep not found. Install it before running this script."
  exit 1
fi

echo "ℹ️ Running Semgrep static analysis..."

if semgrep --config p/default --error .; then
  echo "✅ Semgrep passed"
  exit 0
else
  echo "❌ Semgrep found issues"
  exit 1
fi
