# Prose/TableBlankLines

Equivalent intent: markdownlint MD058.

Requires a blank line before and after each table, except at document boundaries; whitespace-only lines and empty blockquote lines count as blank.

```yaml
Prose/TableBlankLines:
  Enabled: true
```

Autocorrection inserts blank lines without changing table rows and keeps inserted blockquote lines inside the quote; newline spelling follows the source buffer, which normalizes CRLF input to LF.

Unlike an AST-only MD058 implementation, a pipe-containing header and dash delimiter row can identify a table even when adjacent prose or malformed body rows prevent GFM from creating a table node.

Escaped pipes and matching backtick spans are respected when finding the table boundaries; code, raw HTML blocks, ignored YAML front matter, and prose without a table delimiter row are excluded.
