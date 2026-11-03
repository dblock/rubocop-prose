# Markdown/OrderedListNumbering

Enforces sequential numbering or repeated ones. Sequential numbering starts at each list's first number, including zero; nested and quoted lists are checked independently.

Autocorrection preserves punctuation. Changes in number width are report-only because they can affect continuation indentation.

## Configuration

```yaml
Markdown/OrderedListNumbering:
  Enabled: false
  EnforcedStyle: sequential # Or ones, requiring every marker to be 1.
```

## Example

### Bad

```markdown
1. one
1. two
```

### Good

```markdown
1. one
2. two
```
