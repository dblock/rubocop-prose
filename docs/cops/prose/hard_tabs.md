# Prose/HardTabs

Reports hard tabs in Markdown and plain text. Plain-text files are literal, so every tab is reported, including tabs in lines that resemble fences or language labels. In Markdown, front matter is ignored and fenced-code contents are ignored by default; `CodeBlocks` and `AllowedCodeLanguages` retain their Markdown behavior.

Report-only: tabs may be intentional for alignment, Makefiles, or embedded code. The default-enabled rule reports tabs in plain text as well as Markdown.

## Configuration

```yaml
Prose/HardTabs:
  Enabled: true
  CodeBlocks: false # Markdown only: set true to inspect fenced-code contents.
  AllowedCodeLanguages: [] # Markdown only: case-insensitive fenced languages to exempt, such as make.
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

Plain-text files are checked literally, so a tab in a fence-like line or its body is still reported:

```ruby
"```make\tlabel\n\tcommand\n```\n"
```

## Migrating From 0.1.0

Rename `Markdown/HardTabs` to `Prose/HardTabs`.
