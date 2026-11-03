# Prose/MaxLength

Wraps or unwraps Markdown and plain-text paragraphs. Markdown formatting preserves nesting, hard breaks, and inline syntax; headings, tables, and code blocks are not reformatted.

See [To Wrap or Not to Wrap in Markdown](https://code.dblock.org/2021/06/07/to-wrap-or-not-to-wrap-in-markdown.html) for the rationale behind unwrapped Markdown paragraphs.

`Max: false` joins soft line breaks with one space, retaining paragraph boundaries and Markdown hard breaks, including `<br>`. Plain text treats markup literally. Indented text paragraphs and unbreakable overlong tokens can report without correction.

Use [Markdown/StructuralLineLength](../markdown/structural_line_length.md) for heading, code-block, and table limits.

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
