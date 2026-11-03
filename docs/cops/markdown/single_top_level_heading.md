# Markdown/SingleTopLevelHeading

Allows at most one heading at the configured top level. Front-matter titles do not count; use [Markdown/FirstHeading](first_heading.md) for that policy.

Report-only: removing or demoting a heading changes structure.

## Configuration

```yaml
Markdown/SingleTopLevelHeading:
  Enabled: false
  Level: 1
```

## Example

### Bad

```markdown
# Guide

# Usage
```

### Good

```markdown
# Guide

## Usage
```
