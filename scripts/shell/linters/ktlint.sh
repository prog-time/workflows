#!/usr/bin/env bash
set -euo pipefail
ERROR_FOUND=0

mapfile -t kt_files < <(find . -type f \( -name "*.kt" -o -name "*.kts" \) \
  -not -path "./.git/*" \
  -not -path "./build/*")

if [ ${#kt_files[@]} -eq 0 ]; then
  echo "⚠️ No .kt/.kts files found. Skipping."
  exit 0
fi

for file in "${kt_files[@]}"; do
  echo "ℹ️ Checking ${file#./}..."
  ktlint "$file" || ERROR_FOUND=1
done

if [[ $ERROR_FOUND -eq 0 ]]; then
  echo "✅ All Kotlin files passed ktlint checks!"
else
  echo "❌ ktlint found issues!"
  exit 1
fi
