# Markdown/TableColumns

Enabled by default.

Reports delimiter and body rows whose structural cell count differs from the header; empty cells count, exterior pipes do not count as extra cells, and escaped pipes and pipes inside matching backtick runs are literal content.

The cop does not autocorrect because adding or removing cells could discard content or invent structure.

This cop recognizes a pipe-containing header and dash delimiter row inside parser-recognized prose even when inconsistent column counts cause GFM to reject the table.

Root and blockquote tables are supported; code, raw HTML blocks, ignored YAML front matter, ordinary pipe-containing prose without a delimiter row, and table-like text outside parser-recognized prose are excluded.

## Examples

For this configuration:

```yaml
Markdown/TableColumns:
  Enabled: true
```

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
