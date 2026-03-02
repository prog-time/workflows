# Rules Directory — Master Orchestrator

> **Purpose:** Single entry point for AI agents working on this CI Workflows repository.
> **Context:** Read this file first before adding, editing, or reviewing any workflow snippet.
> **Version:** 1.0

---

## 1. Project Overview

This repository contains **reusable GitHub Actions job snippets** — not full workflows.
Each file under `CI/` defines a single **job** to be included in a caller workflow via `jobs.<job-name>` composition.

```
CI/
├─ linters/
│  ├─ hadolint.yml       ← Dockerfile linting
│  ├─ htmlhint.yml       ← HTML linting
│  ├─ markdownlint.yml   ← Markdown linting
│  ├─ shellcheck.yml     ← Shell script linting
│  ├─ stylelint.yml      ← CSS/SCSS/LESS linting
│  └─ yamllint.yml       ← YAML linting
├─ static_analysis/
│  └─ phpstan.yml        ← PHP static analysis (PHP 8.2)
└─ tests/
   └─ laravel_tests.yml  ← Laravel test runner (SQLite, ParaTest)
```

---

## 2. Reading Order

| # | File | When to read |
|---|------|--------------|
| 1 | `_meta/how-to-write-rules.md` | Before creating or editing any rules file |
| 2 | `process/architecture-design.md` | Before adding a new CI snippet or changing structure |
| 3 | `process/ci-cd.md` | Before writing or modifying any `.yml` snippet in `CI/` |

---

## 3. Self-Verification Checklist

Before marking a task complete, the agent **must** confirm:

- [ ] Snippet is placed in the correct `CI/{category}/` directory
- [ ] Job runs on `ubuntu-latest`
- [ ] `actions/checkout@v4` is the first step
- [ ] Config file existence is validated before the tool runs
- [ ] Missing files produce a graceful skip (`⚠️ ... Skipping.`, `exit 0`), not an error
- [ ] All output uses the standard emoji conventions (✅ ❌ ⚠️ ℹ️)
- [ ] `ERROR_FOUND=0` accumulator pattern used when checking multiple files
- [ ] PHP jobs use `shivammathur/setup-php@v2` and `actions/cache@v4` for Composer
- [ ] Node.js jobs install dependencies with `npm ci`
- [ ] Snippet is self-contained — no cross-file dependencies
