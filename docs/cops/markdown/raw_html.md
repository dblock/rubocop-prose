# Markdown/RawHtml

Reports opening HTML elements recognized by the Markdown parser, including inline elements, block elements, nested elements, and table cells; closing tags are not separate offenses.

Code blocks, inline code, escaped tags, comments, autolinks, and ignored YAML front matter are excluded.

This cop follows the GFM AST and does not infer HTML from tag-looking text that the parser treats as literal text; it does not autocorrect because removing HTML could remove content or structure.

## Configuration

```yaml
Markdown/RawHtml:
  Enabled: false
  AllowedElements: [] # Case-insensitive element names without angle brackets.
```

## Example

### Bad

```markdown
<b>Important</b>
```

### Good

```markdown
**Important**
```
