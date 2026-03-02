#!/usr/bin/env bash
ERROR_FOUND=0
DIRS=("scripts" "docker/scripts")

for DIR in "${DIRS[@]}"; do
  if [ ! -d "$DIR" ]; then
    echo "⚠️ Directory $DIR does not exist. Skipping."
    continue
  fi

  echo "ℹ️ Checking directory: $DIR"

  sh_files=$(find "$DIR" -type f -name "*.sh")
  if [ -z "$sh_files" ]; then
    echo "No .sh files found in $DIR"
    continue
  fi

  for file in $sh_files; do
    echo "ℹ️ Checking $file..."
    shellcheck --severity=warning "$file" || ERROR_FOUND=1
  done
done

if [[ $ERROR_FOUND -eq 0 ]]; then
  echo "✅ All shell scripts passed important ShellCheck checks!"
else
  echo "❌ ShellCheck found important issues!"
  exit 1
fi
