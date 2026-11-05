# Prose/MultipleBlankLines

Removes excess consecutive blank lines while preserving paragraph separation. In Markdown, marker-only blank lines inside one parsed blockquote count toward the same limit; code blocks and ignored metadata are left alone. Plain text is checked literally without interpreting quote-looking lines as Markdown.

[Markdown/BlockquoteBlankLines](../markdown/blockquote_blank_lines.md) handles the separate case of adding markers between adjacent blockquotes.

Empty quote lines with the single trailing space permitted by [Markdown/TrailingWhitespace](../markdown/trailing_whitespace.md)'s `AllowEmptyBlockquoteSpace` option still count toward `Max`; retained lines keep their original spelling.

At Markdown structural boundaries, the effective limit is at least the minimum required by the enabled [heading](../markdown/heading_blank_lines.md), [fence](../markdown/fence_blank_lines.md), [list](../markdown/list_blank_lines.md), or [table](../markdown/table_blank_lines.md) spacing cop in that file's configuration. Shared boundaries use the largest minimum, not their sum. `Max` still applies elsewhere, including document edges where no structural padding is required.

## Configuration

```yaml
Prose/MultipleBlankLines:
  Enabled: true
  Max: 1 # Non-negative integer; 0 is report-only to preserve paragraph separation.
```

## Example

For this configuration:

```yaml
Prose/MultipleBlankLines:
  Max: 1
```

### Bad

```markdown
First paragraph.


Second paragraph.

> First paragraph.
>
>
> Second paragraph.
```

### Good

```markdown
First paragraph.

Second paragraph.

> First paragraph.
>
> Second paragraph.
```
