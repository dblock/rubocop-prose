# Text/TrailingWhitespace

Removes all trailing spaces and tabs from plain-text lines, including whitespace-only lines.

## Configuration

```yaml
Text/TrailingWhitespace:
  Enabled: true
```

## Example

Inputs are shown as Ruby strings so trailing whitespace and newline characters are visible.

### Bad

```ruby
"A paragraph.  \n"
```

### Good

```ruby
"A paragraph.\n"
```
