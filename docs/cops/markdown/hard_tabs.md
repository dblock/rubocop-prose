# Markdown/HardTabs

Reports hard tabs, with configurable code-language exceptions.

Report-only: replacing tabs can change embedded code or Makefiles.

## Configuration

```yaml
Markdown/HardTabs:
  Enabled: true
  CodeBlocks: false # Preserve tabs in code examples; set true to inspect code.
  AllowedCodeLanguages: [] # Case-insensitive fenced languages to exempt, such as make.
```

## Example

Inputs are shown as Ruby strings so tabs, trailing spaces, and newline characters are visible.

### Bad

```ruby
"A\tparagraph.\n"
```

### Good

```ruby
"A paragraph.\n"
```
