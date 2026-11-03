# Prose/CodeSpanSpacing

Equivalent intent: markdownlint MD038.

Reports edge whitespace in matched inline code spans in parser-recognized prose, headings, and tables, while preserving all-space code values and symmetric padding needed to separate literal edge backticks from the delimiters.

```yaml
Prose/CodeSpanSpacing:
  Enabled: true
```

Autocorrection removes exactly one redundant space from each edge of a single-line span, retaining its original delimiter length; `` ` foo ` `` becomes `` `foo` ``.

One-sided padding, multiple edge spaces, and multiline padding are reported without autocorrection because removing them can change the code value; necessary backtick padding and all-space values are accepted.

Unlike an aggressive MD038 trim, this cop never shortens backtick runs or strips semantically significant code whitespace; code blocks, escaped backticks, links and labels, HTML, and ignored front matter are excluded.
