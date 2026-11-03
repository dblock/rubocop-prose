# Markdown/ThematicBreakStyle

Consistent mode uses the exact marker spelling of the first parser-recognized thematic break in the document.

Autocorrection replaces only the marker sequence, preserving indentation, blockquote prefixes, and trailing whitespace.

Setext heading underlines, list markers, code, and ignored YAML front matter are not thematic breaks; the parser decides which lines qualify.

## Configuration

```yaml
Markdown/ThematicBreakStyle:
  Enabled: true
  Style: consistent # consistent or a literal valid thematic break, such as ---, *** or * * *.
```

## Example

For this configuration:

```yaml
Markdown/ThematicBreakStyle:
  Style: "* * *"
```

### Bad

```markdown
Text.

---
```

### Good

```markdown
Text.

* * *
```
