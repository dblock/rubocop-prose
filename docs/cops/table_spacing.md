# Prose/TableSpacing

Equivalent intent: markdownlint MD060.

`Style` accepts `aligned` (the default), `compact`, or `tight`; aligned mode uses one leading space and pads each column to its widest source cell, compact mode uses exactly one space adjacent to a pipe, and tight mode removes cell-edge padding.

```yaml
Prose/TableSpacing:
  Enabled: true
  Style: compact
```

Autocorrection changes only cell-edge whitespace, preserving cell contents, internal spaces, escaped pipes, backtick delimiters, alignment colons, outer pipe presence, and container prefixes.

Empty cells remain empty; compact empty cells use one shared space, and alignment measures source characters rather than terminal display width or rendered Markdown width.

Unlike MD060 variants with an `any` style or noncanonical alignment layouts, this cop enforces one configured canonical layout; code, raw HTML blocks, ignored front matter, and pipe-containing prose without a header and dash delimiter row are excluded.
