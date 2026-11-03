# Prose/MaxLength

Opt-in paragraph formatting for Markdown and plain text. `Max` is a positive character count (default `80`), including Markdown container prefixes, or `false` to keep each paragraph on one source line. Markdown corrections preserve list/blockquote prefixes and do not split links, inline code, HTML atoms, escapes, or task-list markers. Markdown code blocks, front matter, tables, and headings are never reformatted by paragraph corrections.

Unbreakable tokens can remain over the limit and report without a usable correction.

With `Max: false`, soft source line breaks are joined with one space. Blank lines still separate paragraphs, and Markdown hard breaks, `<br>` boundaries, multiline inline code, and HTML-only blocks retain their semantics. In `.txt`, those characters are literal and do not suppress reflow. Indented text paragraphs are report-only because indentation may represent preformatted content.

`IgnoreURLs: true` ignores paragraph lines containing only one URL; disable it for strict URL reporting. Heading, code-block, and table limits belong to the separate [Markdown/StructuralLineLength](../markdown/structural_line_length.md) cop.

## Examples

For this configuration:

```yaml
Prose/MaxLength:
  Enabled: true
  Max: false
```

### Bad

```markdown
A paragraph split
across two source lines.
```

### Good

```markdown
A paragraph split across two source lines.
```
