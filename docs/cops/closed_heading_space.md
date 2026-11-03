# Prose/ClosedHeadingSpace

Disabled by default.

Reports a parsed ATX heading with trailing unescaped hashes attached to its text, such as `# Title#`. Properly separated closing hashes and escaped terminal hashes are accepted; code and front matter are excluded.

This intentionally checks only parser-recognized ATX headings, leaving missing opening separators to `Prose/AtxHeadingSpace`. Literal suffixes such as `# C#` are necessarily ambiguous and are reported, not silently reinterpreted.

Report-only: adding a separator removes the hash suffix from the rendered heading text.

## Examples

For this configuration:

```yaml
Prose/ClosedHeadingSpace:
  Enabled: true
```

### Bad

```markdown
# Title#
```

### Good

```markdown
# Title #
```
