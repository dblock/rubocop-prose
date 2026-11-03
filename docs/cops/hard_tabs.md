# Prose/HardTabs

Opt-in hard-tab diagnostics with original character columns. `CodeBlocks` defaults to `true`; set it to `false` to ignore code. `AllowedCodeLanguages` excludes named fenced languages case-insensitively, such as `make`.

This rule is report-only: a tab's intended width and meaning depend on context, and replacing tabs inside embedded strings or Makefiles is unsafe.

## Examples

For this configuration:

```yaml
Prose/HardTabs:
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
