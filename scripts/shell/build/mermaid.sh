#!/usr/bin/env bash
set -euo pipefail
ERROR_FOUND=0

mapfile -t mmd_files < <(find . -type f -name "*.mmd" \
  -not -path "./node_modules/*" \
  -not -path "./.git/*")

if [ ${#mmd_files[@]} -eq 0 ]; then
  echo "⚠️ No .mmd files found. Skipping."
  exit 0
fi

PUPPETEER_CONFIG=$(mktemp /tmp/puppeteer-XXXXXX.json)
echo '{"args":["--no-sandbox"]}' > "$PUPPETEER_CONFIG"
trap 'rm -f "$PUPPETEER_CONFIG"' EXIT

for file in "${mmd_files[@]}"; do
  out="${file%.mmd}.svg"
  echo "ℹ️ Rendering ${file#./} → ${out#./}..."
  mmdc -i "$file" -o "$out" -p "$PUPPETEER_CONFIG" || ERROR_FOUND=1
done

if [[ $ERROR_FOUND -eq 0 ]]; then
  echo "✅ All .mmd files rendered successfully!"
else
  echo "❌ mermaid-cli failed to render some files!"
  exit 1
fi
