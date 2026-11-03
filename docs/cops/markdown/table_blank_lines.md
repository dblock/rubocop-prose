# Markdown/TableBlankLines

Enabled by default.

Requires a blank line before and after each table, except at document boundaries; whitespace-only lines and empty blockquote lines count as blank.

Autocorrection inserts blank lines without changing table rows and keeps inserted blockquote lines inside the quote; newline spelling follows the source buffer, which normalizes CRLF input to LF.

A pipe-containing header and dash delimiter row can identify a table even when adjacent prose or malformed body rows prevent GFM from creating a table node.

Escaped pipes and matching backtick spans are respected when finding the table boundaries; code, raw HTML blocks, ignored YAML front matter, and prose without a table delimiter row are excluded.

## Examples

For this configuration:

```yaml
Markdown/TableBlankLines:
  Enabled: true
```

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
