# Prose/TrailingNewline

Ensures nonempty documents end in exactly one newline, inserting a missing newline or removing trailing blank lines. Empty files are accepted; internal content is unchanged.

## Configuration

```yaml
Prose/TrailingNewline:
  Enabled: true
```

## Example

Inputs are shown as Ruby strings so tabs, trailing spaces, and newline characters are visible.

### Bad

```ruby
"A paragraph."
```

### Good

```ruby
"A paragraph.\n"
```
