# Prose/MaxLength

Formats paragraphs in Markdown and plain text. Markdown corrections preserve list/blockquote prefixes and do not split links, inline code, HTML atoms, escapes, or task-list markers. Markdown code blocks, front matter, tables, and headings are never reformatted by paragraph corrections.

See [To Wrap or Not to Wrap in Markdown](https://code.dblock.org/2021/06/07/to-wrap-or-not-to-wrap-in-markdown.html) for the rationale behind unwrapped Markdown paragraphs.

When wrapping is configured, unbreakable tokens can remain over the limit and report without a usable correction.

With `Max: false`, soft source line breaks are joined with one space. Blank lines still separate paragraphs, and Markdown hard breaks, `<br>` boundaries, multiline inline code, and HTML-only blocks retain their semantics. In `.txt`, those characters are literal and do not suppress reflow. Indented text paragraphs are report-only because indentation may represent preformatted content.

Heading, code-block, and table limits belong to the separate [Markdown/StructuralLineLength](../markdown/structural_line_length.md) cop.

## Configuration

```yaml
Prose/MaxLength:
  Enabled: true
  Max: false # One source line per paragraph; a positive character count wraps, including container prefixes.
  IgnoreURLs: true # Ignore paragraph lines containing only one URL.
```

## Example

### Bad

```markdown
A paragraph split
across two source lines.
```

### Good

```markdown
A paragraph split across two source lines.
```
