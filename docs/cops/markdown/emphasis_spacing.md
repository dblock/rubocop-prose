# Markdown/EmphasisSpacing

Enabled by default.

Reports whitespace immediately inside a balanced, single-line pair of `*`, `_`, `**`, `__`, `***`, or `___` delimiters in parser-recognized prose, headings, and tables.

Autocorrection removes only the inner edge whitespace and preserves internal whitespace, links, backticks, and delimiter spelling; for example, `** two  words **` becomes `**two  words**`.

Code, links and their labels, escaped delimiters, HTML spans and blocks, ignored YAML front matter, thematic breaks, and actual list markers are excluded.

This cop requires matching delimiters on one line and nonempty content; it intentionally does not rewrite multiline or unmatched emphasis.

## Examples

For this configuration:

```yaml
Markdown/EmphasisSpacing:
  Enabled: true
```

### Bad

```markdown
Some * padded * text.
```

### Good

```markdown
Some *padded* text.
```
