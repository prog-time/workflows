#!/usr/bin/env bash
set -euo pipefail
ERROR_FOUND=0

if [ ! -f ".yamllint.yml" ]; then
  echo "::error::Config file .yamllint.yml not found"
  exit 1
fi

mapfile -t yaml_files < <(find . -type f \( -name "*.yml" -o -name "*.yaml" \) \
  -not -path "./_site/*" \
  -not -path "./node_modules/*" \
  -not -path "./.git/*" \
  -not -name ".yamllint.yml")

if [ ${#yaml_files[@]} -eq 0 ]; then
  echo "⚠️ No YAML files found. Skipping."
  exit 0
fi

for file in "${yaml_files[@]}"; do
  echo "ℹ️ Checking ${file#./}..."
  yamllint "$file" || ERROR_FOUND=1
done

if [[ $ERROR_FOUND -eq 0 ]]; then
  echo "✅ All YAML files passed yamllint checks!"
else
  echo "❌ yamllint found issues!"
  exit 1
fi
