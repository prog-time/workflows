#!/usr/bin/env bash
DOCKERFILES=("Dockerfile" "docker/node/Dockerfile")
IGNORE_RULES="DL3008|DL3015"
ERROR_FOUND=0

for FILE in "${DOCKERFILES[@]}"; do
  if [[ ! -f "$FILE" ]]; then
    echo "⚠️ $FILE not found. Skipping."
    continue
  fi

  echo "🔍 Checking $FILE ..."

  output=$(hadolint "$FILE" 2>&1 | grep -vE "$IGNORE_RULES" || true)
  if [[ -n "$output" ]]; then
    echo "❌ Issues found in $FILE:"
    echo "$output"
    ERROR_FOUND=1
  else
    echo "✅ $FILE passed Hadolint checks!"
  fi
done

if [[ $ERROR_FOUND -eq 0 ]]; then
  echo "✅ All Dockerfiles passed Hadolint checks!"
else
  echo "❌ Hadolint found issues in one or more Dockerfiles!"
  exit 1
fi
