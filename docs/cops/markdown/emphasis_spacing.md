# Markdown/EmphasisSpacing

Removes whitespace just inside matching emphasis delimiters on a single line, preserving the content and delimiter style. For example, `** two  words **` becomes `**two  words**`.

## Configuration

```yaml
Markdown/EmphasisSpacing:
  Enabled: true
```

## Example

### Bad

```markdown
Some * padded * text.
```

### Good

```markdown
Some *padded* text.
```
