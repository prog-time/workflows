#!/usr/bin/env bash
set -euo pipefail
ERROR_FOUND=0

mapfile -t rb_files < <(find . -type f -name "*.rb" \
  -not -path "./.git/*" \
  -not -path "./vendor/*")

if [ ${#rb_files[@]} -eq 0 ]; then
  echo "⚠️ No .rb files found. Skipping."
  exit 0
fi

for file in "${rb_files[@]}"; do
  echo "ℹ️ Checking ${file#./}..."
  rubocop "$file" || ERROR_FOUND=1
done

if [[ $ERROR_FOUND -eq 0 ]]; then
  echo "✅ All Ruby files passed RuboCop checks!"
else
  echo "❌ RuboCop found issues!"
  exit 1
fi
