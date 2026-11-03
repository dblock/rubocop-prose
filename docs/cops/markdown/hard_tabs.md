# Markdown/HardTabs

Enabled by default. Hard-tab diagnostics with original character columns. `CodeBlocks` defaults to `false` to preserve tabs in code examples; set it to `true` to inspect code. `AllowedCodeLanguages` excludes named fenced languages case-insensitively, such as `make`.

This rule is report-only: a tab's intended width and meaning depend on context, and replacing tabs inside embedded strings or Makefiles is unsafe.

## Examples

For this configuration:

```yaml
Markdown/HardTabs:
  Enabled: true
```

Inputs are shown as Ruby strings so tabs, trailing spaces, and newline characters are visible.

### Bad

```ruby
"A\tparagraph.\n"
```

### Good

```ruby
"A paragraph.\n"
```
