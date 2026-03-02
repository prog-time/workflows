#!/usr/bin/env bash
set -euo pipefail
ERROR_FOUND=0

CONFIG_FOUND=0
for config in ".eslintrc.json" ".eslintrc.js" ".eslintrc.yml" ".eslintrc.yaml" "eslint.config.js" "eslint.config.mjs" "eslint.config.cjs"; do
  if [ -f "$config" ]; then
    CONFIG_FOUND=1
    break
  fi
done

if [ $CONFIG_FOUND -eq 0 ]; then
  echo "::error::No ESLint config file found"
  exit 1
fi

mapfile -t js_files < <(find . -type f \( -name "*.js" -o -name "*.jsx" -o -name "*.ts" -o -name "*.tsx" -o -name "*.mjs" -o -name "*.cjs" \) \
  -not -path "./_site/*" \
  -not -path "./node_modules/*" \
  -not -path "./.git/*")

if [ ${#js_files[@]} -eq 0 ]; then
  echo "⚠️ No JS/TS files found. Skipping."
  exit 0
fi

for file in "${js_files[@]}"; do
  echo "ℹ️ Checking ${file#./}..."
  npx eslint "$file" || ERROR_FOUND=1
done

if [[ $ERROR_FOUND -eq 0 ]]; then
  echo "✅ All JS/TS files passed ESLint checks!"
else
  echo "❌ ESLint found issues!"
  exit 1
fi
