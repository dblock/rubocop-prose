# Markdown/FrontMatterSyntax

Reports YAML syntax errors in closed leading Markdown front matter. The cop is enabled by default and report-only. It parses YAML syntax without constructing Ruby objects or validating metadata against a schema; valid scalar values such as dates and custom-tagged nodes are accepted.

The cop checks only a closed leading header and reports the YAML parser's line and column in the original Markdown source. It works independently of `Markdown: IgnoreFrontMatter`, which controls how other Markdown cops handle metadata.

## Configuration

```yaml
Markdown/FrontMatterSyntax:
  Enabled: true
```

## Example

### Bad

```markdown
---
title: [Unclosed list
---
```

### Good

```markdown
---
title: A valid title
date: 2026-11-04
tags: [ruby, markdown]
---
```
