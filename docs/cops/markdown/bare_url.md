# Markdown/BareUrl

Reports bare URLs in prose. Use `<https://example.test/docs>` or `[the documentation](https://example.test/docs)` instead.

Report-only: choose an autolink or descriptive label when fixing the URL.

## Configuration

```yaml
Markdown/BareUrl:
  Enabled: false
  Schemes: # An empty list disables URL matching.
    - http
    - https
    - ftp
```

## Example

### Bad

```markdown
Visit https://example.test/guide.
```

### Good

```markdown
Visit [the guide](https://example.test/guide).
```
