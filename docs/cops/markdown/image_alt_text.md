# Markdown/ImageAltText

Requires nonblank alternative text for Markdown images, including reference images and images inside links.

Report-only: add a meaningful description inside the brackets.

## Configuration

```yaml
Markdown/ImageAltText:
  Enabled: true
```

## Example

### Bad

```markdown
![](/logo.png)
```

### Good

```markdown
![Project logo](/logo.png)
```
