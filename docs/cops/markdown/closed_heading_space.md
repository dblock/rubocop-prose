# Markdown/ClosedHeadingSpace

Reports hashes attached to the end of heading text, such as `# Title#`. Missing opening separators belong to [Markdown/AtxHeadingSpace](atx_heading_space.md).

Report-only: suffixes such as `# C#` may be intentional, and adding a space changes the heading's rendered text.

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
