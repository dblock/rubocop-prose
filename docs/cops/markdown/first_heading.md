# Markdown/FirstHeading

Requires the first content line to be a heading at the configured level, unless the configured front-matter metadata key contains a nonempty string. The default key is `title`; set `FrontMatterTitle: false` to require a heading even when front matter contains a title. Empty documents are accepted.

Front-matter titles must be strings; YAML aliases are not accepted. Report-only: adding or moving a heading changes structure.

## Configuration

```yaml
Markdown/FirstHeading:
  Enabled: false
  Level: 1
  FrontMatterTitle: title # Exact top-level YAML key, or false to disable the exemption.
```

## Example

### Bad

```markdown
An introduction to the project.
```

### Good

```markdown
# Introduction

An introduction to the project.
```

### Good Front Matter Title

```markdown
---
title: Introduction
---

An introduction to the project.
```

## Migrating From 0.1.0

In 0.1.0, `FrontMatterTitle: true` enabled the exemption and `TitleKey` selected the metadata key. Replace that pair with one setting: a nonempty key string, or `false` to disable the exemption. For example, migrate a custom `name` key as follows:

```yaml
# Before
Markdown/FirstHeading:
  FrontMatterTitle: true
  TitleKey: name

# After
Markdown/FirstHeading:
  FrontMatterTitle: name
```

`TitleKey` is obsolete and causes a configuration error with migration guidance. Use `FrontMatterTitle: false` when the front matter should not satisfy this cop.
