# Markdown/TableSpacing

Formats table padding without changing cell contents: `aligned` pads columns to their widest source cell, `compact` uses one space beside pipes, and `tight` removes padding.

Alignment counts source characters, not display width. Empty cells stay empty.

## Configuration

```yaml
Markdown/TableSpacing:
  Enabled: true
  Style: aligned
  SupportedStyles:
    - aligned
    - compact
    - tight
```

## Example

For this configuration:

```yaml
Markdown/TableSpacing:
  Style: compact
```

### Bad

```markdown
|A|B|
|---|---|
|one|two|
```

### Good

```markdown
| A | B |
| --- | --- |
| one | two |
```
