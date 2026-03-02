# Contributing

## Adding a new snippet

Each snippet is one tool, one category. Follow these four steps:

**1. Write the bash script** — `scripts/shell/<category>/<tool>.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail
ERROR_FOUND=0

# Validate config exists
if [ ! -f ".toolrc" ]; then
  echo "::error::Config file .toolrc not found"
  exit 1
fi

# Collect files
mapfile -t files < <(find . -type f -name "*.ext" \
  -not -path "./_site/*" \
  -not -path "./node_modules/*" \
  -not -path "./.git/*")

# Graceful skip
if [ ${#files[@]} -eq 0 ]; then
  echo "⚠️ No files found. Skipping."
  exit 0
fi

# Check all files, accumulate errors
for file in "${files[@]}"; do
  echo "ℹ️ Checking ${file#./}..."
  tool "$file" || ERROR_FOUND=1
done

if [[ $ERROR_FOUND -eq 0 ]]; then
  echo "✅ All files passed!"
else
  echo "❌ Issues found!"
  exit 1
fi
```

**2. Write BATS tests** — `tests/<category>/<tool>.bats`

Cover: missing config, no files found, all pass, one fails.
See existing tests in `tests/linters/` for examples.

**3. Create the source YAML** — `scripts/CI/<category>/<tool>.yml`

```yaml
<tool>:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - name: Install <tool>
      run: ...
    - name: Run <tool>
      run: bash scripts/shell/<category>/<tool>.sh
```

**4. Assemble and verify** — generate the output file and check it's committed:

```bash
bash scripts/assemble-ci.sh scripts/CI/<category> scripts/shell/<category> CI/<category>
git diff CI/   # must be empty
```

---

## Mandatory rules

See `rules/process/ci-cd.md` for the full reference. The short version:

- `runs-on: ubuntu-latest` always
- `actions/checkout@v4` must be the first step
- Actions pinned to major version tag (`@v4`, `@v2`) — never `@latest`
- Config validated with `::error::` before the tool runs
- No files → `⚠️ ... Skipping.` + `exit 0`
- Multi-file checks use the `ERROR_FOUND=0` accumulator (never `set -e` as a substitute)
- Node.js: `npm ci`, never `npm install`
- PHP: `shivammathur/setup-php@v2` + `actions/cache@v4` for Composer
- Output emoji: `✅` pass · `❌` fail · `⚠️` skip · `ℹ️` per-file progress

---

## Running tests locally

```bash
# Install bats-core (macOS)
brew install bats-core

# Run all tests
bats --recursive tests/
```

---

## Pull request checklist

- [ ] Script is in `scripts/shell/<category>/`
- [ ] Source YAML is in `scripts/CI/<category>/`
- [ ] Assembled output is committed to `CI/<category>/`
- [ ] `git diff CI/` is clean after running the assembler
- [ ] BATS tests added and passing
- [ ] All mandatory rules from `rules/process/ci-cd.md` satisfied
