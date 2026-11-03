# Markdown/EmphasisHeading

Reports single-line paragraphs consisting entirely of italic or bold text, such as `**Overview**`, including in lists and blockquotes.

Report-only: the paragraph may be intentional; otherwise, choose an appropriate heading level.

## Configuration

```yaml
Markdown/EmphasisHeading:
  Enabled: false
```

## Example

### Bad

```markdown
*Installation*
```

### Good

```markdown
## Installation
```
