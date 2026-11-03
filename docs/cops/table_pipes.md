# Prose/TablePipes

Disabled by default.

`Style` accepts `consistent` (the default), `leading_and_trailing`, `leading_only`, `trailing_only`, or `no_leading_or_trailing`; consistent mode independently follows each table header's leading and trailing pipe presence.

Autocorrection adds or removes only exterior structural pipes while preserving cell text, internal whitespace, indentation, blockquote prefixes, and trailing whitespace.

Removing pipes from a single-column table or an empty boundary cell can change the table's meaning, so these offenses have no unsafe correction.

The table tokenizer ignores escaped pipes and pipes inside matching inline backtick runs; header-plus-delimiter tables remain recognizable when a malformed body makes GFM reject them.

Tables must have a pipe-containing header and a delimiter row of colon-wrapped dash cells inside parser-recognized prose or tables; fenced and indented code, raw HTML blocks, ignored front matter, and pipe-containing ordinary text are excluded.

## Examples

For this configuration:

```yaml
Prose/TablePipes:
  Enabled: true
  Style: "leading_and_trailing"
```

### Bad

```markdown
A | B
--- | ---
one | two
```

### Good

```markdown
| A | B |
| --- | --- |
| one | two |
```
