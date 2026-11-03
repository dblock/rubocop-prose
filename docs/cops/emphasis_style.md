# Prose/EmphasisStyle

Equivalent intent: markdownlint MD049.

`Style` accepts `consistent` (the default), `asterisk`, or `underscore`; consistent mode follows the first parsed emphasis span in document order.

```yaml
Prose/EmphasisStyle:
  Enabled: true
  Style: underscore
```

The cop uses parser-recognized emphasis rather than guessing from punctuation, including nested and multiline emphasis in prose and headings and inline emphasis in tables; strong emphasis is checked separately by `Prose/StrongStyle`.

Autocorrection replaces only the opening and closing delimiters, preserving content and container prefixes; intraword asterisk emphasis is reported but not changed to underscores because that would stop being emphasis.

Code, links including labels, escaped delimiters, HTML, and ignored YAML front matter are excluded; unlike textual MD049 checks, intraword underscores that the parser does not recognize as emphasis are not offenses.
