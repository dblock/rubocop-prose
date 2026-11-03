# Markdown/EmptyLink

Reports links with an empty destination or just `#`, including reference links. Empty labels with real destinations and images are not checked.

Report-only: supply the intended destination.

## Configuration

```yaml
Markdown/EmptyLink:
  Enabled: true
```

## Example

### Bad

```markdown
[Read the guide]()
```

### Good

```markdown
[Read the guide](/guide)
```
