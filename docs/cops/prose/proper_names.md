# Prose/ProperNames

Corrects configured names to their canonical capitalization in Markdown and plain text. Matching is case-insensitive, uses whole-word boundaries, and treats punctuation in names literally.

Plain text is checked literally: Markdown-like code, links, URLs, and fences receive no special treatment. In Markdown, code spans, fenced code, links, escaped syntax, HTML, and front matter are excluded by default. `CodeBlocks` includes Markdown code spans and fenced-code contents when enabled; fence language labels are never checked.

The former `Markdown/ProperNames` name is obsolete; RuboCop reports the migration to `Prose/ProperNames` when an old configuration is loaded.

## Configuration

```yaml
Prose/ProperNames:
  Enabled: false
  Names: [] # Canonical spellings; an empty list disables checks.
  CodeBlocks: false # Markdown only: also check inline code and fenced-code contents.
```

## Example

For this configuration:

```yaml
Prose/ProperNames:
  Enabled: true
  Names:
    - GitHub
    - Ruby
    - C++
```

### Bad

```markdown
Use github and ruby.
```

### Good

```markdown
Use GitHub and Ruby.
```

In plain text, markup-looking syntax is also checked literally:

### Plain-Text Input

```text
`github` https://github.com
```

### Corrected Text

```text
`GitHub` https://GitHub.com
```
