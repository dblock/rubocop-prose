# Markdown/HeadingBlankLines

Requires the configured blank lines around headings, measuring below the underline for Setext headings. Document boundaries and the end of front matter do not require padding; empty blockquote lines count as blank.

Report-only: inserting blank lines can change surrounding lists and blockquotes.

[Prose/MultipleBlankLines](../prose/multiple_blank_lines.md) preserves these minimums at heading boundaries without relaxing its limit elsewhere.

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
