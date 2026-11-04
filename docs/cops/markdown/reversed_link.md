# Markdown/ReversedLink

Reports reversed link syntax such as `(Documentation)[https://example.test]`. Use `[Documentation](https://example.test)` instead. Valid references and single citation-shaped keys such as `(abbrev)[@citekey]` or `(abbrev)[-@citekey]` are left alone. This is a narrow diagnostic exclusion, not full Pandoc or R Markdown citation support.

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
