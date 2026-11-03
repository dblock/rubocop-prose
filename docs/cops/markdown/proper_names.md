# Markdown/ProperNames

Configured canonical spellings are matched case-insensitively with Unicode letter, digit, and underscore boundaries. Punctuation within configured names is literal.

Autocorrection replaces only a matched name with its configured capitalization in prose, headings, and table cells.

Links including labels and destinations, HTML including its contents, escaped characters, and ignored YAML front matter are excluded; this cop excludes code unless explicitly enabled and deliberately does not enforce capitalization inside link labels or raw HTML.

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
