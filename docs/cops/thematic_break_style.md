# Prose/ThematicBreakStyle

Disabled by default.

`Style` defaults to `consistent`, which uses the exact marker spelling of the first parser-recognized thematic break in the document; alternatively, configure a literal valid thematic break such as `---`, `***`, or `* * *`.

Autocorrection replaces only the marker sequence, preserving indentation, blockquote prefixes, and trailing whitespace.

Setext heading underlines, list markers, code, and ignored YAML front matter are not thematic breaks; the parser decides which lines qualify.

## Examples

For this configuration:

```yaml
Prose/ThematicBreakStyle:
  Enabled: true
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
