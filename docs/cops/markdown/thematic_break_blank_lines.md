# Markdown/ThematicBreakBlankLines

Requires one blank line above and below each parsed thematic break. Document boundaries and a preceding front-matter header do not require padding. Blockquote markers and list indentation are retained on inserted blank lines.

For counts above one, also raise [Prose/MultipleBlankLines](../prose/multiple_blank_lines.md)'s `Max` to permit them.

## Configuration

```yaml
Markdown/ThematicBreakBlankLines:
  Enabled: true
  LinesAbove: 1 # Nonnegative minimum; zero disables checks above breaks.
  LinesBelow: 1 # Nonnegative minimum; zero disables checks below breaks.
```

## Example

### Bad

```markdown
***
After.
```

### Good

```markdown
***

After.
```
