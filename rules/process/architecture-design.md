# Architecture Design

> **Purpose:** Define structural rules for organizing CI snippet files in this repository.
> **Context:** Read before adding a new snippet, renaming a file, or reorganizing the `CI/` directory.
> **Version:** 1.0

---

## 1. Directory Structure

Place every snippet in the correct category directory under `CI/`:

| Category | Path | Contents |
|----------|------|----------|
| Linters | `CI/linters/` | Code style and syntax checks |
| Static analysis | `CI/static_analysis/` | Type checkers, code analyzers |
| Tests | `CI/tests/` | Test runners |

```
# ✅ Correct
CI/linters/eslint.yml
CI/static_analysis/phpstan.yml
CI/tests/laravel_tests.yml

# ❌ Incorrect — wrong category, flat structure
CI/eslint.yml
CI/phpstan_and_tests.yml
```

---

## 2. File Naming

- Use lowercase and underscores only: `tool_name.yml`
- Name the file after the tool it runs: `hadolint.yml`, `phpstan.yml`
- One tool per file — never combine two tools in one snippet

```
# ✅ Correct
CI/linters/shellcheck.yml

# ❌ Incorrect — multiple tools, camelCase
CI/linters/shellcheck_and_hadolint.yml
CI/linters/ShellCheck.yml
```

---

## 3. Snippet Scope

Every file defines exactly **one job**. The top-level key is the job name:

```yaml
# ✅ Correct — single root job key
shellcheck:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    ...
```

```yaml
# ❌ Incorrect — full workflow wrapper inside a snippet file
name: CI
on: [push]
jobs:
  shellcheck:
    ...
```

---

## 4. Adding a New Snippet

When adding a new CI snippet, the agent must:

1. Identify the correct category (`linters`, `static_analysis`, or `tests`)
2. Create a single file named after the tool
3. Follow the job structure rules in `process/ci-cd.md`
4. Verify the snippet is self-contained — it must not reference other files in `CI/`

---

## Checklist

- [ ] File placed in `CI/{correct-category}/`
- [ ] File named after the tool in lowercase with underscores
- [ ] Single job defined per file
- [ ] No full `workflow` wrapper (`name:`, `on:`, `jobs:`) inside snippet files
- [ ] No cross-file dependencies
