# Prose/ClosedHeadingSpacing

Disabled by default.

Reports multiple spaces or tabs before a parser-recognized closing ATX hash run, such as `# Title  #`. Autocorrection replaces only that separator with one space; the closing markers and trailing whitespace are preserved.

Escaped hashes, attached literal suffixes, non-closed headings, code and front matter are excluded. A single tab is accepted; the rule measures separator length without normalizing tabs.

## Examples

For this configuration:

```yaml
Prose/ClosedHeadingSpacing:
  Enabled: true
```

### Bad

```markdown
# Title  #
```

### Good

```markdown
# Title #
```
