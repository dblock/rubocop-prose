# Markdown/TrailingWhitespace

Paragraph hard breaks are retained and normalized to the configured width; stray spaces, tabs, and whitespace-only lines are trimmed. Heading spacing is not mistaken for a paragraph hard break.

Front matter follows the shared setting. Configuring zero hard-break spaces is rejected rather than silently deleting rendered breaks.

## Configuration

```yaml
Markdown/TrailingWhitespace:
  Enabled: true
  HardBreakSpaces: 2 # Must be an integer of at least 2.
  CodeBlocks: false # When true, code whitespace is report-only to preserve embedded strings.
```

## Example

Inputs are shown as Ruby strings so tabs, trailing spaces, and newline characters are visible.

### Bad

```ruby
"A paragraph. \n"
```

### Good

```ruby
"A paragraph.\n"
```
