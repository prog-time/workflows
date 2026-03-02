#!/usr/bin/env bash
set -euo pipefail
ERROR_FOUND=0

if [ ! -f ".stylelintrc.json" ]; then
  echo "::error::Config file .stylelintrc.json not found"
  exit 1
fi

mapfile -t css_files < <(find . -type f \( -name "*.css" -o -name "*.scss" -o -name "*.less" \) \
  -not -path "./_site/*" \
  -not -path "./node_modules/*")

if [ ${#css_files[@]} -eq 0 ]; then
  echo "⚠️ No CSS/SCSS/LESS files found. Skipping."
  exit 0
fi

for file in "${css_files[@]}"; do
  echo "ℹ️ Checking ${file#./}..."
  npx stylelint "$file" || ERROR_FOUND=1
done

if [[ $ERROR_FOUND -eq 0 ]]; then
  echo "✅ All CSS/SCSS/LESS files passed stylelint checks!"
else
  echo "❌ stylelint found issues!"
  exit 1
fi
