# Markdown/TableColumns

Requires delimiter and body rows to have the same number of cells as the header. Empty cells count; escaped pipes and pipes inside inline code are cell content.

Report-only: adding or removing cells can lose content.

## Configuration

```yaml
Markdown/TableColumns:
  Enabled: true
```

## Example

### Bad

```markdown
| A | B |
| --- | --- |
| one |
```

### Good

```markdown
| A | B |
| --- | --- |
| one | two |
```
