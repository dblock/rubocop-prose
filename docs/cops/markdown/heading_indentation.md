# Markdown/HeadingIndentation

Reports indentation before headings or their outermost container marker; `> # Title` is accepted only without leading spaces. For Setext headings, only the text line's indentation is checked.

Report-only: removing indentation can change the surrounding structure.

## Configuration

```yaml
Markdown/HeadingIndentation:
  Enabled: true
```

## Example

### Bad

```markdown
 # Title
```

### Good

```markdown
# Title
```
