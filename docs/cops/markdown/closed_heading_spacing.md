# Markdown/ClosedHeadingSpacing

Reports multiple spaces or tabs before a parser-recognized closing ATX hash run, such as `# Title  #`. Autocorrection replaces only that separator with one space; the closing markers and trailing whitespace are preserved.

Escaped hashes, attached literal suffixes, non-closed headings, code and front matter are excluded. A single tab is accepted; the rule measures separator length without normalizing tabs.

## Configuration

```yaml
Markdown/ClosedHeadingSpacing:
  Enabled: true
```

## Example

### Bad

```markdown
# Title  #
```

### Good

```markdown
# Title #
```
