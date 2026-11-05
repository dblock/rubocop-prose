# Markdown/HardTabs

Reports hard tabs in Markdown. Front matter and code-block contents are ignored by default. Enable `CodeBlocks` to inspect code contents; `AllowedCodeLanguages` exempts configured fenced languages.

Report-only: tabs may be intentional for alignment, Makefiles, or embedded code. Use [Text/HardTabs](../text/hard_tabs.md) for literal plain-text files.

## Configuration

```yaml
Markdown/HardTabs:
  Enabled: true
  CodeBlocks: false # Set true to inspect code-block contents.
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
