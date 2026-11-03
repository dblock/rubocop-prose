# Markdown/HeadingIncrement

Reports skipped heading levels, such as `# Title` followed by `### Detail`. The first heading can have any level, and decreases are unrestricted.

Report-only: choose the appropriate heading level.

## Configuration

```yaml
Markdown/HeadingIncrement:
  Enabled: true
```

## Example

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
