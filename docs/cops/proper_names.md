# Prose/ProperNames

Disabled by default.

`Names` supplies canonical spellings and defaults to `[]`; matching is case-insensitive with Unicode letter, digit, and underscore boundaries, and punctuation within configured names is literal.

Autocorrection replaces only a matched name with its configured capitalization in prose, headings, and table cells.

`CodeBlocks: false` excludes both inline code and code blocks; setting it to `true` checks both kinds of code, but never fence info strings.

Links including labels and destinations, HTML including its contents, escaped characters, and ignored YAML front matter are excluded; this cop excludes code unless explicitly enabled and deliberately does not enforce capitalization inside link labels or raw HTML.

## Examples

For this configuration:

```yaml
Prose/ProperNames:
  Enabled: true
  Names: ["GitHub", "Ruby", "C++"]
  CodeBlocks: false
```

### Bad

```markdown
Use github and ruby.
```

### Good

```markdown
Use GitHub and Ruby.
```
