# Markdown/HeadingBlankLines

Boundaries of the document and the end of front matter do not require padding.

Checks parsed ATX and Setext headings, measuring after the underline for Setext syntax. Whitespace-only and blockquote-marker-only lines count as blank; fenced and indented code are not headings. Container boundaries are inspected as physical source lines.

Report-only: adding blank lines can change lists, blockquotes and paragraph interpretation.

## Configuration

```yaml
Markdown/HeadingBlankLines:
  Enabled: true
  LinesAbove: 1 # Minimum blank lines before a heading; 0 disables this requirement.
  LinesBelow: 1 # Minimum blank lines after a heading; 0 disables this requirement.
```

## Example

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
