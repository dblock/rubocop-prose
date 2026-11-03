# Prose/MultipleBlankLines

Removes excess consecutive blank lines while preserving paragraph separation. Markdown code blocks and ignored metadata are left alone; plain text is checked literally.

Blank blockquote markers are handled by [Markdown/BlockquoteBlankLines](../markdown/blockquote_blank_lines.md) rather than counted as empty lines here.

## Configuration

```yaml
Prose/MultipleBlankLines:
  Enabled: true
  Max: 1 # Non-negative integer; 0 is report-only to preserve paragraph separation.
```

## Example

### Bad

```markdown
First paragraph.


Second paragraph.
```

### Good

```markdown
First paragraph.

Second paragraph.
```
