# Markdown/FrontMatterKeys

Checks allowed and required top-level keys in a closed leading YAML front-matter block. Key names are exact and case-sensitive. Nested keys and values are not checked. Required keys must be present, but may have empty values.

`AllowedKeys: null` permits any key; `[]` permits none. `RequiredKeys` lists keys that must appear and must be included in `AllowedKeys` when that allowlist is configured. A document without front matter is skipped; an empty front-matter block is checked for missing keys.

Checks run even when `Markdown/IgnoreFrontMatter` is true. Malformed YAML is skipped so `Markdown/FrontMatterSyntax` can report syntax errors separately. Non-mapping YAML and complex or alias keys are reported. YAML merge keys (`<<`) are treated as literal keys, not expanded; quoted scalar keys are compared by their decoded text. Parsing uses the YAML syntax tree and never instantiates tagged Ruby objects.

Report-only: removing unknown metadata or inventing required values could lose data or change behavior.

## Configuration

```yaml
Markdown/FrontMatterKeys:
  Enabled: false
  AllowedKeys: null
  RequiredKeys: []
```

## Example

For this configuration:

```yaml
Markdown/FrontMatterKeys:
  Enabled: true
  AllowedKeys:
    - title
    - date
    - tags
  RequiredKeys:
    - title
```

### Bad

```markdown
---
titel: Getting Started
date: 2026-11-05
---

# Getting Started
```

### Good

```markdown
---
title: Getting Started
date: 2026-11-05
tags:
  - ruby
---

# Getting Started
```
