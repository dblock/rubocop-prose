# Prose/ThematicBreakStyle

Equivalent intent: markdownlint MD035.

`Style` defaults to `consistent`, which uses the exact marker spelling of the first parser-recognized thematic break in the document; alternatively, configure a literal valid thematic break such as `---`, `***`, or `* * *`.

```yaml
Prose/ThematicBreakStyle:
  Enabled: true
  Style: '* * *'
```

Autocorrection replaces only the marker sequence, preserving indentation, blockquote prefixes, and trailing whitespace.

Setext heading underlines, list markers, code, and ignored YAML front matter are not thematic breaks; unlike a line-pattern implementation of MD035, the parser decides which lines qualify.
