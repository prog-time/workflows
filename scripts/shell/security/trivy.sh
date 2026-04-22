#!/usr/bin/env bash
set -euo pipefail

if ! command -v trivy &> /dev/null; then
  echo "::error::trivy not found. Install it before running this script."
  exit 1
fi

echo "ℹ️ Running Trivy filesystem scan..."

if trivy fs --exit-code 1 --severity HIGH,CRITICAL --no-progress .; then
  echo "✅ No HIGH/CRITICAL vulnerabilities"
  exit 0
else
  echo "❌ Trivy found HIGH/CRITICAL vulnerabilities"
  exit 1
fi
