# Prose/ProperNames

Equivalent intent: markdownlint MD044.

`Names` supplies canonical spellings and defaults to `[]`; matching is case-insensitive with Unicode letter, digit, and underscore boundaries, and punctuation within configured names is literal.

```yaml
Prose/ProperNames:
  Enabled: true
  Names: [GitHub, Ruby, C++]
  CodeBlocks: false
```

Autocorrection replaces only a matched name with its configured capitalization in prose, headings, and table cells.

`CodeBlocks: false` excludes both inline code and code blocks; setting it to `true` checks both kinds of code, but never fence info strings.

Links including labels and destinations, HTML including its contents, escaped characters, and ignored YAML front matter are excluded; unlike markdownlint's defaults, this cop excludes code unless explicitly enabled and deliberately does not enforce capitalization inside link labels or raw HTML.
