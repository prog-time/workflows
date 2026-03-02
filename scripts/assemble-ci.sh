#!/usr/bin/env bash
set -euo pipefail

LINTERS_DIR="${1:-scripts/CI/linters}"
SCRIPTS_DIR="${2:-scripts/shell/linters}"
DIST_DIR="${3:-CI/linters}"

mkdir -p "$DIST_DIR"

process_file() {
  local yaml_file="$1"
  local name
  name="$(basename "$yaml_file" .yml)"
  local sh_file="${SCRIPTS_DIR}/${name}.sh"
  local dist_file="${DIST_DIR}/${name}.yml"
  local pattern
  local indent=""

  if [[ ! -f "$sh_file" ]]; then
    cp "$yaml_file" "$dist_file"
    printf '⚠️  %s: script not found, copied as-is → %s\n' "$name" "$dist_file"
    return
  fi

  pattern="^([[:space:]]*)run:[[:space:]]bash[[:space:]]${SCRIPTS_DIR}/${name}\.sh[[:space:]]*$"

  {
    while IFS= read -r line || [[ -n "$line" ]]; do
      if [[ "$line" =~ $pattern ]]; then
        indent="${BASH_REMATCH[1]}"
        printf '%s\n' "${indent}run: |"
        while IFS= read -r sh_line || [[ -n "$sh_line" ]]; do
          if [[ -z "$sh_line" ]]; then
            printf '\n'
          else
            printf '%s\n' "${indent}  ${sh_line}"
          fi
        done < <(awk 'NR==1 && /^#!/ { next } { print }' "$sh_file")
      else
        printf '%s\n' "$line"
      fi
    done < "$yaml_file"
  } > "$dist_file"

  printf '✅ %s → %s\n' "$name" "$dist_file"
}

for yaml_file in "$LINTERS_DIR"/*.yml; do
  process_file "$yaml_file"
done
