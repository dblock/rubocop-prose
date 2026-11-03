# Markdown/FirstHeading

Requires the first nonblank content line to begin a parsed heading at the configured level. ATX and Setext headings qualify; leading prose, HTML and code do not. Empty and front-matter-only documents are accepted.

Invalid or unsafe YAML, aliases and non-string titles do not qualify for a front-matter title exemption.

Parsed container headings count if they begin on the first content line. Report-only: adding or moving a title changes structure.

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
