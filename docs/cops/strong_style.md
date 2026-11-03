# Prose/StrongStyle

Equivalent intent: markdownlint MD050.

`Style` accepts `consistent` (the default), `asterisk`, or `underscore`; consistent mode follows the first parsed strong span in document order.

```yaml
Prose/StrongStyle:
  Enabled: true
  Style: asterisk
```

The cop checks parser-recognized strong emphasis, including nesting and multiline spans in prose and headings and inline spans in tables; ordinary emphasis is checked separately by `Prose/EmphasisStyle`.

Autocorrection changes only `**` or `__` delimiters, preserving the enclosed text and any nested emphasis; intraword asterisk strong spans are reported without an underscore correction when that correction would lose the formatting.

Code, links including labels, escaped delimiters, HTML, and ignored YAML front matter are excluded; unlike textual MD050 checks, intraword underscores that the parser does not recognize as strong emphasis are not offenses.
