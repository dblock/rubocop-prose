# Prose/RawHtml

Equivalent intent: markdownlint MD033.

Reports opening HTML elements recognized by the Markdown parser, including inline elements, block elements, nested elements, and table cells; closing tags are not separate offenses.

`AllowedElements` is a case-insensitive list of element names without angle brackets; its default is `[]`.

```yaml
Prose/RawHtml:
  Enabled: true
  AllowedElements: [br, details, summary]
```

Code blocks, inline code, escaped tags, comments, autolinks, and ignored YAML front matter are excluded.

Unlike a text-based MD033 implementation, this cop follows the GFM AST and does not infer HTML from tag-looking text that the parser treats as literal text; it does not autocorrect because removing HTML could remove content or structure.
