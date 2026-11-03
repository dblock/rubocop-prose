# Markdown/AtxHeadingSpace

Reports a missing separator after one to six opening heading hashes, such as `##Title`, including in lists and blockquotes. A space or tab is accepted.

Report-only: inserting a space could turn intentional text into a heading.

## Configuration

```yaml
Markdown/AtxHeadingSpace:
  Enabled: true
```

## Example

### Bad

```markdown
#Title
```

### Good

```markdown
# Title
```
