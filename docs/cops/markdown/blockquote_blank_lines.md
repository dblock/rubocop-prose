# Markdown/BlockquoteBlankLines

Adds quote markers to blank lines between adjacent blockquotes, preserving nesting and indentation.

This treats adjacent quotes as one quotation. Separate them with other content if they should remain distinct.

## Configuration

```yaml
Markdown/BlockquoteBlankLines:
  Enabled: true
```

## Example

### Bad

```markdown
> First paragraph.

> Second paragraph.
```

### Good

```markdown
> First paragraph.
>
> Second paragraph.
```
