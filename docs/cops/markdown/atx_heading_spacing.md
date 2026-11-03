# Markdown/AtxHeadingSpacing

Enabled by default.

Reports two or more spaces or tabs between a parsed ATX opening marker and non-whitespace content. Autocorrection replaces only that separator with one space, retaining container prefixes and Unicode text.

Empty headings without content are ignored; a closing hash run counts as content for spacing purposes. A single tab is accepted, intentionally checking separator length rather than implementing a separate tab policy. Code, escaped markers and front matter are excluded.

## Examples

For this configuration:

```yaml
Markdown/AtxHeadingSpacing:
  Enabled: true
```

### Bad

```markdown
#  Title
```

### Good

```markdown
# Title
```
