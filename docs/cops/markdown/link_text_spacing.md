# Markdown/LinkTextSpacing

Trims leading and trailing whitespace from inline and reference link labels without changing their targets. Images and autolinks are not checked.

Whitespace-only labels are report-only because trimming them could change the link syntax.

## Configuration

```yaml
Markdown/LinkTextSpacing:
  Enabled: true
```

## Example

### Bad

```markdown
[ guide ](/guide)
```

### Good

```markdown
[guide](/guide)
```
