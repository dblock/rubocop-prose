# Markdown/TableSpacing

Aligned mode uses one leading space and pads each column to its widest source cell, compact mode uses exactly one space adjacent to a pipe, and tight mode removes cell-edge padding.

Autocorrection changes only cell-edge whitespace, preserving cell contents, internal spaces, escaped pipes, backtick delimiters, alignment colons, outer pipe presence, and container prefixes.

Empty cells remain empty; compact empty cells use one shared space, and alignment measures source characters rather than terminal display width or rendered Markdown width.

This cop enforces one configured canonical layout; code, raw HTML blocks, ignored front matter, and pipe-containing prose without a header and dash delimiter row are excluded.

## Configuration

```yaml
Markdown/TableSpacing:
  Enabled: true
  Style: aligned # aligned, compact or tight.
```

## Example

For this configuration:

```yaml
Markdown/TableSpacing:
  Style: compact
```

### Bad

```markdown
|A|B|
|---|---|
|one|two|
```

### Good

```markdown
| A | B |
| --- | --- |
| one | two |
```
