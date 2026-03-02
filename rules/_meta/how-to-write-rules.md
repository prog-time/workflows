# How to Write Rules

> **Purpose:** Define the standard every rules file in this directory must meet.
> **Context:** Read this file before creating or updating any file inside `rules/`.
> **Version:** 1.0

---

## 1. Mandatory Structure

Every `.md` file in `rules/` must contain:

1. A `# Title` matching the file's subject
2. A `> Purpose / Context` blockquote at the top
3. Numbered sections with clear, imperative headings
4. At least one ✅ Correct and one ❌ Incorrect example per major rule
5. A `## Checklist` section at the end

---

## 2. Writing Style

- Write all rules in **English**
- Use short, imperative sentences: "Use X", "Never do Y", "Always Z"
- Avoid vague qualifiers: "try to", "consider", "might want to"
- Use second person: "the agent must", "you must"

---

## 3. YAML Snippet Examples

```yaml
# ✅ Correct — config file check, graceful skip, accumulator pattern
- name: Run yamllint
  run: |
    ERROR_FOUND=0

    if [ ! -f ".yamllint.yml" ]; then
      echo "::error::Config file .yamllint.yml not found"
      exit 1
    fi

    mapfile -t yaml_files < <(find . -type f -name "*.yml" \
      -not -path "./.git/*" \
      -not -path "./node_modules/*")

    if [ ${#yaml_files[@]} -eq 0 ]; then
      echo "⚠️ No YAML files found. Skipping."
      exit 0
    fi

    for file in "${yaml_files[@]}"; do
      echo "ℹ️ Checking ${file#./}..."
      yamllint "$file" || ERROR_FOUND=1
    done

    if [[ $ERROR_FOUND -eq 0 ]]; then
      echo "✅ All YAML files passed!"
    else
      echo "❌ Issues found!"
      exit 1
    fi
```

```yaml
# ❌ Incorrect — no config check, exits on first error, no summary
- name: Run yamllint
  run: yamllint .
```

---

## 4. Scope

- Each rules file covers **one concern only**
- Do not mix linter rules with PHP rules in one file
- Mark non-applicable sections with `_Not applicable — reason_`

---

## Checklist

- [ ] File has `# Title` and `> Context` blockquote
- [ ] Numbered sections with imperative headings
- [ ] At least one ✅ and ❌ example
- [ ] Rules are short and unambiguous
- [ ] `## Checklist` present at the end
