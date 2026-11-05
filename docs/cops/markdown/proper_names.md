# Markdown/ProperNames

Corrects configured names to their canonical capitalization in Markdown. Matching is case-insensitive, uses whole-word boundaries, and treats punctuation in names literally.

Code spans, code blocks, links, escaped syntax, HTML, and front matter are excluded by default. `CodeBlocks` includes code spans and code-block contents when enabled; fence language labels are never checked. Use [Text/ProperNames](../text/proper_names.md) for literal plain-text files.

## Configuration

```yaml
Markdown/ProperNames:
  Enabled: false
  Names: [] # Canonical spellings; an empty list disables checks.
  CodeBlocks: false # Also check inline code and code-block contents.
```

## Example

For this configuration:

```yaml
Markdown/ProperNames:
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
