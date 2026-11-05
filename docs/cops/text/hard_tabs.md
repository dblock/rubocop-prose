# Text/HardTabs

Reports every hard tab in plain-text files without correction. Markdown-like fences, code, and metadata are literal text and receive no exemptions.

Use [Markdown/HardTabs](../markdown/hard_tabs.md) for Markdown code-block and language exceptions.

## Configuration

```yaml
Text/HardTabs:
  Enabled: true
```

## Example

Inputs are shown as Ruby strings so tabs and newline characters are visible.

### Bad

```ruby
"A\tparagraph.\n"
```

### Good

```ruby
"A paragraph.\n"
```
