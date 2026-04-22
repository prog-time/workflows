#!/usr/bin/env bash
set -euo pipefail

# Config detection: .sqlfluff, pyproject.toml with [tool.sqlfluff], or setup.cfg with sqlfluff section
CONFIG_FOUND=0

if [[ -f ".sqlfluff" ]]; then
  CONFIG_FOUND=1
elif [[ -f "pyproject.toml" ]] && grep -q '\[tool\.sqlfluff\]' pyproject.toml; then
  CONFIG_FOUND=1
elif [[ -f "setup.cfg" ]] && grep -q '\[sqlfluff\]' setup.cfg; then
  CONFIG_FOUND=1
fi

if [[ $CONFIG_FOUND -eq 0 ]]; then
  echo "::error::No SQLFluff config found (.sqlfluff, pyproject.toml [tool.sqlfluff], or setup.cfg [sqlfluff])"
  exit 1
fi

SQL_COUNT=$(find . -type f -name "*.sql" \
  -not -path "./node_modules/*" \
  -not -path "./.git/*" \
  -not -path "./_site/*" | wc -l | tr -d ' ')

if [[ "$SQL_COUNT" -eq 0 ]]; then
  echo "⚠️ No SQL files found. Skipping."
  exit 0
fi

if sqlfluff lint .; then
  echo "✅ SQLFluff passed"
else
  echo "❌ SQLFluff found issues"
  exit 1
fi
