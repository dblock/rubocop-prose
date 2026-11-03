# Markdown/ClosedHeadingSpace

Reports a parsed ATX heading with trailing unescaped hashes attached to its text, such as `# Title#`. Properly separated closing hashes and escaped terminal hashes are accepted; code and front matter are excluded.

This intentionally checks only parser-recognized ATX headings, leaving missing opening separators to [Markdown/AtxHeadingSpace](atx_heading_space.md). Literal suffixes such as `# C#` are necessarily ambiguous and are reported, not silently reinterpreted.

Report-only: adding a separator removes the hash suffix from the rendered heading text.

## Configuration

```yaml
Markdown/ClosedHeadingSpace:
  Enabled: true
```

## Example

### Bad

```markdown
# Title#
```

### Good

```markdown
# Title #
```
