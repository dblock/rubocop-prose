# Prose/TableColumns

Equivalent intent: markdownlint MD056.

Reports delimiter and body rows whose structural cell count differs from the header; empty cells count, exterior pipes do not count as extra cells, and escaped pipes and pipes inside matching backtick runs are literal content.

```yaml
Prose/TableColumns:
  Enabled: true
```

The cop does not autocorrect because adding or removing cells could discard content or invent structure.

Unlike an AST-only MD056 implementation, this cop recognizes a pipe-containing header and dash delimiter row inside parser-recognized prose even when inconsistent column counts cause GFM to reject the table.

Root and blockquote tables are supported; code, raw HTML blocks, ignored YAML front matter, ordinary pipe-containing prose without a delimiter row, and table-like text outside parser-recognized prose are excluded.
