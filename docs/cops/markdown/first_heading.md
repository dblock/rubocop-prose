# Markdown/FirstHeading

Requires the first content line to be a heading at the configured level, unless a configured front-matter title qualifies. Empty documents are accepted.

Front-matter titles must be strings; YAML aliases are not accepted. Report-only: adding or moving a heading changes structure.

## Configuration

```yaml
Markdown/FirstHeading:
  Enabled: false
  Level: 1
  FrontMatterTitle: true # Accept a nonempty front-matter title instead of a heading.
  TitleKey: title # Exact top-level YAML key, not a regular expression.
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
