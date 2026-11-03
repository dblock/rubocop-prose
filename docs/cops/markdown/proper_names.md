# Markdown/ProperNames

Corrects configured names to their canonical capitalization in prose, headings, and tables. Matching is case-insensitive, uses whole-word boundaries, and treats punctuation in names literally.

Code is checked only when enabled.

## Configuration

```yaml
Markdown/ProperNames:
  Enabled: false
  Names: [] # Canonical spellings; an empty list disables checks.
  CodeBlocks: false # Set true to check inline code and code blocks, but never fence info strings.
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
