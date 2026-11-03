# Markdown/CodeSpanSpacing

Reports unnecessary padding inside inline code. All-space values and padding needed around literal backticks are accepted.

Autocorrection removes a single redundant space from each edge of a single-line span: `` ` foo ` `` becomes `` `foo` ``. Other padding is report-only because removing it can change the code value.

## Configuration

```yaml
Markdown/CodeSpanSpacing:
  Enabled: true
```

## Example

### Bad

```markdown
Use ` code ` here.
```

### Good

```markdown
Use `code` here.
```
