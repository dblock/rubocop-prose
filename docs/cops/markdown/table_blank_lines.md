# Markdown/TableBlankLines

Adds blank lines around Markdown tables without changing their rows or blockquote nesting. Document boundaries need no padding; empty blockquote lines count as blank.

## Configuration

```yaml
Markdown/TableBlankLines:
  Enabled: true
```

## Example

### Bad

```markdown
Before.
| A | B |
| --- | --- |
| one | two |
After.
```

### Good

```markdown
Before.

| A | B |
| --- | --- |
| one | two |

After.
```
