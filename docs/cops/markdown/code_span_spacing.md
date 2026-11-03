# Markdown/CodeSpanSpacing

Disabled by default.

Reports edge whitespace in matched inline code spans in parser-recognized prose, headings, and tables, while preserving all-space code values and symmetric padding needed to separate literal edge backticks from the delimiters.

Autocorrection removes exactly one redundant space from each edge of a single-line span, retaining its original delimiter length; `` ` foo ` `` becomes `` `foo` ``.

One-sided padding, multiple edge spaces, and multiline padding are reported without autocorrection because removing them can change the code value; necessary backtick padding and all-space values are accepted.

This cop never shortens backtick runs or strips semantically significant code whitespace; code blocks, escaped backticks, links and labels, HTML, and ignored front matter are excluded.

## Examples

For this configuration:

```yaml
Markdown/CodeSpanSpacing:
  Enabled: true
```

### Bad

```markdown
Use ` code ` here.
```

### Good

```markdown
Use `code` here.
```
