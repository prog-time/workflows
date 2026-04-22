#!/usr/bin/env bash
set -euo pipefail

if ! command -v pip-audit &> /dev/null; then
  echo "::error::pip-audit not found. Install it before running this script."
  exit 1
fi

REQ_FILE=""
if [[ -f "requirements.txt" ]]; then
  REQ_FILE="requirements.txt"
elif [[ -f "pyproject.toml" ]]; then
  REQ_FILE="pyproject.toml"
elif [[ -f "Pipfile.lock" ]]; then
  REQ_FILE="Pipfile.lock"
fi

if [[ -z "$REQ_FILE" ]]; then
  echo "::error::No Python requirements file found (requirements.txt, pyproject.toml, or Pipfile.lock)."
  exit 1
fi

echo "ℹ️ Running pip-audit on $REQ_FILE..."

if [[ "$REQ_FILE" == "requirements.txt" ]]; then
  pip-audit --strict -r requirements.txt
else
  pip-audit --strict
fi

echo "✅ pip-audit passed"
