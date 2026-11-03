# Markdown/SingleTopLevelHeading

Every parsed heading at the configured top level after the first is reported; documents without one are allowed.

Both ATX and Setext headings count, including parsed container headings. Front-matter titles do not count as headings for this cop; use [Markdown/FirstHeading](first_heading.md) for a front-matter title policy. Code and escaped markers do not count.

Report-only: removing or demoting a heading changes document structure.

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
