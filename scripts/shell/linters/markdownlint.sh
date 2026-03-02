#!/usr/bin/env bash
set -euo pipefail
ERROR_FOUND=0

if [ ! -f ".markdownlint.yml" ]; then
  echo "::error::Config file .markdownlint.yml not found"
  exit 1
fi

mapfile -t md_files < <(find . -type f -name "*.md" \
  -not -path "./node_modules/*" \
  -not -path "./_site/*" \
  -not -path "./.git/*" \
  -not -path "./rules/*")

if [ ${#md_files[@]} -eq 0 ]; then
  echo "⚠️ No .md files found. Skipping."
  exit 0
fi

for file in "${md_files[@]}"; do
  echo "ℹ️ Checking ${file#./}..."
  markdownlint "$file" || ERROR_FOUND=1
done

if [[ $ERROR_FOUND -eq 0 ]]; then
  echo "✅ All markdown files passed markdownlint checks!"
else
  echo "❌ markdownlint found issues!"
  exit 1
fi
