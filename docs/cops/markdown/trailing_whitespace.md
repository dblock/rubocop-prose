# Markdown/TrailingWhitespace

Trims trailing whitespace while preserving paragraph hard breaks at the configured width. Hard-break width must be positive.

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
