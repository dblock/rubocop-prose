# Prose/MultipleBlankLines

Removes excess consecutive blank lines while preserving paragraph separation. Markdown code blocks and ignored metadata are left alone; plain text is checked literally.

Blank blockquote markers are handled by [Markdown/BlockquoteBlankLines](../markdown/blockquote_blank_lines.md) rather than counted as empty lines here.

At Markdown structural boundaries, the effective limit is at least the minimum required by the enabled [heading](../markdown/heading_blank_lines.md), [fence](../markdown/fence_blank_lines.md), [list](../markdown/list_blank_lines.md), or [table](../markdown/table_blank_lines.md) spacing cop in that file's configuration. Shared boundaries use the largest minimum, not their sum. `Max` still applies elsewhere, including document edges where no structural padding is required.

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
