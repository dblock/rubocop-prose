# Markdown/ReversedLink

Reports reversed link syntax such as `(Documentation)[https://example.test]`. Use `[Documentation](https://example.test)` instead. Valid references are left alone.

Report-only: review the intended link before rewriting it.

## Configuration

```yaml
Markdown/ReversedLink:
  Enabled: true
```

## Example

### Bad

```markdown
(Read the guide)[/guide]
```

### Good

```markdown
[Read the guide](/guide)
```
