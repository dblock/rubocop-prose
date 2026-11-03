# Markdown/HardTabs

Hard-tab diagnostics with original character columns.

This rule is report-only: a tab's intended width and meaning depend on context, and replacing tabs inside embedded strings or Makefiles is unsafe.

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
