# Markdown/HeadingIncrement

Disabled by default.

Reports a parsed heading whose level increases by more than one from the preceding heading, for example `# Title` followed by `### Detail`; decreases and an initial heading at any level are allowed.

ATX, closed ATX and Setext headings participate, including parsed container headings; fenced code, indented code, escaped markers and front matter do not.

Report-only: choosing a replacement heading level would change the document structure.

## Examples

For this configuration:

```yaml
Markdown/HeadingIncrement:
  Enabled: true
```

### Bad

```markdown
# Guide

### Usage
```

### Good

```markdown
# Guide

## Usage
```
