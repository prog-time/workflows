#!/usr/bin/env bash
set -euo pipefail
ERROR_FOUND=0

if [ ! -f ".htmlhintrc" ]; then
  echo "::error::Config file .htmlhintrc not found"
  exit 1
fi

mapfile -t html_files < <(find . -type f -name "*.html" \
  -not -path "./_site/*" \
  -not -path "./node_modules/*")

if [ ${#html_files[@]} -eq 0 ]; then
  echo "⚠️ No .html files found. Skipping."
  exit 0
fi

for file in "${html_files[@]}"; do
  echo "ℹ️ Checking ${file#./}..."
  output=$(npx htmlhint "$file" 2>&1) || ERROR_FOUND=1
  echo "$output" | grep -v "Config loaded:" | grep -v "Scanned [0-9]* files, no errors found"
done

if [[ $ERROR_FOUND -eq 0 ]]; then
  echo "✅ All HTML files passed htmlhint checks!"
else
  echo "❌ htmlhint found issues!"
  exit 1
fi
