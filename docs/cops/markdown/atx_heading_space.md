# Markdown/AtxHeadingSpace

Disabled by default.

Reports one to six opening hashes immediately followed by non-whitespace, such as `##Title`. Empty headings and a single separating tab or space are accepted.

This lexical check recognizes ordinary blockquote and list prefixes, but deliberately does not infer arbitrary Markdown containers; four-space-indented code, fenced code, front matter, escaped opening hashes and runs of seven or more hashes are excluded. Unlike structural cops, it must inspect text that the parser does not recognize as a heading.

Report-only: inserting whitespace could turn intentional prose, tags or identifiers into a heading.

## Examples

For this configuration:

```yaml
Markdown/AtxHeadingSpace:
  Enabled: true
```

### Bad

```markdown
#Title
```

### Good

```markdown
# Title
```
