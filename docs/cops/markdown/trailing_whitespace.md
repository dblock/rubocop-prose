# Markdown/TrailingWhitespace

Trims trailing whitespace while preserving paragraph hard breaks at the configured width. Hard-break width must be positive.

When [Markdown/HardBreakStyle](hard_break_style.md) is enabled, that cop selects the hard-break syntax and this cop avoids overlapping corrections.

Set `AllowEmptyBlockquoteSpace: true` to permit exactly one trailing ASCII space on an otherwise-empty blockquote line, including nested quotes. Bare quote markers remain valid. Two or more trailing spaces, tabs, and mixed trailing whitespace are still rejected; paragraph hard breaks and code-block handling are unchanged.

[Markdown/BlockquoteSpacing](blockquote_spacing.md) leaves empty quote markers alone, and [Markdown/BlockquoteBlankLines](blockquote_blank_lines.md) adds bare markers without requiring a trailing space. [Prose/MultipleBlankLines](../prose/multiple_blank_lines.md) still counts empty quote lines toward `Max`, whether they have the allowed space or not.

## Configuration

```yaml
Markdown/TrailingWhitespace:
  Enabled: true
  HardBreakSpaces: 2 # Must be an integer of at least 2.
  AllowEmptyBlockquoteSpace: false
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

## Empty blockquote lines

For this configuration:

```yaml
Markdown/TrailingWhitespace:
  AllowEmptyBlockquoteSpace: true
```

### Bad

```ruby
"> First paragraph.\n>  \n> Second paragraph.\n"
"> First paragraph.\n>\t\n> Second paragraph.\n"
```

### Good

```ruby
"> First paragraph.\n> \n> Second paragraph.\n"
"> > First paragraph.\n> > \n> > Second paragraph.\n"
"> First paragraph.\n>\n> Second paragraph.\n"
```
