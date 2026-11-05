# Text/ProperNames

Corrects configured names to their canonical capitalization in literal plain text. Matching is case-insensitive, uses whole-word boundaries, and treats punctuation in names literally. Markdown-like code, links, URLs, and fences receive no special treatment.

Use [Markdown/ProperNames](../markdown/proper_names.md) for Markdown syntax exclusions and code-content options.

## Configuration

```yaml
Text/ProperNames:
  Enabled: false
  Names: [] # Canonical spellings; an empty list disables checks.
```

## Example

For this configuration:

```yaml
Text/ProperNames:
  Enabled: true
  Names:
    - GitHub
```

### Bad

```text
`github` https://github.com
```

### Good

```text
`GitHub` https://GitHub.com
```
