# Markdown/ListContinuationIndentation

Requires continuation lines in parsed list-item paragraphs to align with the item's content column. This checks indentation only; it does not require paragraph reflow or sibling marker alignment.

## Configuration

Enabled by default. This cop reports offenses without autocorrection because changing indentation can alter which Markdown item or block owns the text.

```yaml
Markdown/ListContinuationIndentation:
  Enabled: true
```

## Example

### Bad

```markdown
- Item text
continued text.
```

### Good

```markdown
- Item text
  continued text.
```
