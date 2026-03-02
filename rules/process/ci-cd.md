# CI/CD Snippet Rules

> **Purpose:** Define the mandatory patterns every job snippet in `CI/` must follow.
> **Context:** Read before writing or modifying any `.yml` file under `CI/`.
> **Version:** 1.0

---

## 1. Job Skeleton

Every job must follow this structure:

```yaml
# ✅ Correct
<job-name>:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    # tool installation
    # config check (if applicable)
    # run step with ERROR_FOUND pattern
```

Rules:
- `runs-on` must always be `ubuntu-latest`
- `actions/checkout@v4` must be the first step
- No `timeout-minutes` unless the job is known to be slow (PHP jobs: max 15 min)

---

## 2. Error Accumulator Pattern

Use this pattern whenever the job checks **multiple files**. Never exit on the first error — collect all errors and fail at the end.

```yaml
# ✅ Correct
run: |
  ERROR_FOUND=0

  for file in "${files[@]}"; do
    echo "ℹ️ Checking ${file#./}..."
    some-tool "$file" || ERROR_FOUND=1
  done

  if [[ $ERROR_FOUND -eq 0 ]]; then
    echo "✅ All files passed!"
  else
    echo "❌ Issues found!"
    exit 1
  fi
```

```yaml
# ❌ Incorrect — exits on first failure, no summary
run: |
  for file in *.yml; do
    yamllint "$file"
  done
```

---

## 3. Config File Validation

If a tool requires a config file, validate its existence **before** running the tool.

```yaml
# ✅ Correct
if [ ! -f ".yamllint.yml" ]; then
  echo "::error::Config file .yamllint.yml not found"
  exit 1
fi
```

```yaml
# ❌ Incorrect — tool fails with cryptic error if config is missing
yamllint .
```

---

## 4. Graceful Skip When No Files Found

If no target files exist, emit a warning and exit with 0. Never fail the job because there are no files.

```yaml
# ✅ Correct
if [ ${#files[@]} -eq 0 ]; then
  echo "⚠️ No .yml files found. Skipping."
  exit 0
fi
```

```yaml
# ❌ Incorrect — fails or produces confusing output when directory is empty
yamllint .
```

---

## 5. Output Emoji Conventions

Use these consistently in every `echo` statement:

| Emoji | Meaning |
|-------|---------|
| ✅ | Success — all checks passed |
| ❌ | Failure — issues found |
| ⚠️ | Warning — skipped or non-critical |
| ℹ️ | Info — currently processing a file |
| `::error::` | GitHub Actions annotation for hard errors |

---

## 6. PHP Jobs (PHPStan / Laravel Tests)

PHP jobs must include:

1. `shivammathur/setup-php@v2` with `php-version: "8.2"`
2. `actions/cache@v4` for the `vendor/` directory, keyed on `composer.lock`
3. `composer install --no-interaction --prefer-dist`

```yaml
# ✅ Correct
- name: Setup PHP
  uses: shivammathur/setup-php@v2
  with:
    php-version: "8.2"

- name: Cache Composer
  uses: actions/cache@v4
  with:
    path: vendor
    key: composer-${{ hashFiles('composer.lock') }}
    restore-keys: composer-

- name: Install dependencies
  run: composer install --no-interaction --prefer-dist
```

```yaml
# ❌ Incorrect — no cache, no version pin
- name: Install dependencies
  run: composer install
```

---

## 7. Node.js Jobs (htmlhint / stylelint)

Node.js jobs must install dependencies with `npm ci` — never `npm install`.

```yaml
# ✅ Correct
- name: Install dependencies
  run: npm ci
```

```yaml
# ❌ Incorrect
- name: Install dependencies
  run: npm install
```

---

## 8. Action Version Pinning

Always pin actions to a major version tag. Never use `@latest` or a bare branch name.

```yaml
# ✅ Correct
uses: actions/checkout@v4
uses: actions/cache@v4
uses: shivammathur/setup-php@v2

# ❌ Incorrect
uses: actions/checkout@latest
uses: actions/checkout@main
```

---

## 9. Shell Scripts

Bash logic for linter jobs lives in `scripts/linters/*.sh`, not inline in YAML.

- Each script is self-contained with `#!/usr/bin/env bash` and `set -euo pipefail`
- YAML run steps call scripts with a single line: `bash scripts/linters/<tool>.sh`
- All scripts are covered by BATS unit tests in `tests/linters/`

```yaml
# ✅ Correct
- name: Run yamllint
  run: bash scripts/linters/yamllint.sh

# ❌ Incorrect — bash logic inline in YAML
- name: Run yamllint
  run: |
    ERROR_FOUND=0
    ...
```

BATS tests run in CI via `CI/tests/bats.yml`. Run locally with:

```sh
bats tests/linters/
```

---

## Checklist

- [ ] `runs-on: ubuntu-latest`
- [ ] `actions/checkout@v4` is the first step
- [ ] Config file validated before tool runs
- [ ] Missing files produce `⚠️ ... Skipping.` + `exit 0`
- [ ] `ERROR_FOUND=0` accumulator used for multi-file checks
- [ ] Emoji conventions followed (✅ ❌ ⚠️ ℹ️)
- [ ] PHP jobs: `setup-php@v2` + `cache@v4` + `--no-interaction`
- [ ] Node.js jobs: `npm ci` only
- [ ] All action versions pinned to major tag (`@v4`, `@v2`)
- [ ] Bash logic extracted to `scripts/linters/<tool>.sh`, not inline in YAML
- [ ] YAML run step calls `bash scripts/linters/<tool>.sh`
- [ ] Script covered by BATS test in `tests/linters/<tool>.bats`
