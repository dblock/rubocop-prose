# Markdown/StrongStyle

Consistent mode follows the first parsed strong span in document order.

The cop checks parser-recognized strong emphasis, including nesting and multiline spans in prose and headings and inline spans in tables; ordinary emphasis is checked separately by [Markdown/EmphasisStyle](emphasis_style.md).

Autocorrection changes only `**` or `__` delimiters, preserving the enclosed text and any nested emphasis; intraword asterisk strong spans are reported without an underscore correction when that correction would lose the formatting.

Code, links including labels, escaped delimiters, HTML, and ignored YAML front matter are excluded; intraword underscores that the parser does not recognize as strong emphasis are not offenses.

## Configuration

```yaml
Markdown/StrongStyle:
  Enabled: true
  Style: consistent # consistent, asterisk or underscore.
```

## Example

For this configuration:

```yaml
Markdown/StrongStyle:
  Style: underscore
```

### Bad

```markdown
This is **important**.
```

### Good

```markdown
This is __important__.
```
