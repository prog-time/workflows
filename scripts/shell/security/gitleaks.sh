#!/usr/bin/env bash
set -euo pipefail

if ! command -v gitleaks &> /dev/null; then
  echo "::error::gitleaks not found. Install it before running this script."
  exit 1
fi

echo "ℹ️ Running gitleaks on the repository..."

if gitleaks detect --source . --no-banner --redact; then
  echo "No secrets found"
  exit 0
else
  echo "gitleaks found potential secrets"
  exit 1
fi
