# Prose/TrailingNewline

Final-newline normalization. Nonempty Markdown and plain-text documents must end in exactly one newline. Autocorrection inserts a missing newline or removes excess trailing blank lines; empty files are accepted. Embedded source and internal blank lines are untouched.

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
