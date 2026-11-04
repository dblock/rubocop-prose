# Markdown/FenceBlankLines

Requires the configured minimum blank lines above and below fenced code blocks, preserving list and blockquote nesting. Set either count to zero to leave that boundary unchecked. Document boundaries and a preceding front-matter header do not require extra padding.

A fence on a list marker's own line does not require a blank before it.

[Prose/MultipleBlankLines](../prose/multiple_blank_lines.md) preserves these minimums at fence boundaries without relaxing its limit elsewhere.

## Configuration

```yaml
Markdown/FenceBlankLines:
  Enabled: true
  LinesAbove: 1 # Nonnegative minimum; zero disables checks above fences.
  LinesBelow: 1 # Nonnegative minimum; zero disables checks below fences.
  ListItems: true # Set false to skip fences inside list items.
```

## Example

### Bad

````markdown
Example:
```ruby
puts 1
```
More text.
````

### Good

````markdown
Example:

```ruby
puts 1
```

More text.
````
