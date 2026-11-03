# Markdown/HeadingBlankLines

Enabled by default.

`LinesAbove` and `LinesBelow` set minimum blank-line counts, both defaulting to `1`; `0` disables the respective requirement. Boundaries of the document and the end of front matter do not require padding.

Checks parsed ATX and Setext headings, measuring after the underline for Setext syntax. Whitespace-only and blockquote-marker-only lines count as blank; fenced and indented code are not headings. Container boundaries are inspected as physical source lines.

Report-only: adding blank lines can change lists, blockquotes and paragraph interpretation.

## Examples

For this configuration:

```yaml
Markdown/HeadingBlankLines:
  Enabled: true
```

### Bad

```markdown
Introduction.
## Usage
Follow these steps.
```

### Good

```markdown
Introduction.

## Usage

Follow these steps.
```
