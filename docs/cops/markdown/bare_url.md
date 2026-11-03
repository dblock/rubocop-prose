# Markdown/BareUrl

Reports literal URLs in prose. Trailing sentence punctuation and unmatched closing brackets are excluded from the offense range.

Use `<https://example.test/docs>` or `[the documentation](https://example.test/docs)` instead. The rule is report-only: automatically choosing autolinks over descriptive text is an editorial decision.

Markdown links and images (including resolved references), definitions, angle autolinks, code spans/blocks, front matter, HTML tags/comments and raw HTML blocks/regions are excluded. Plain email addresses, `www.` without a scheme, and URLs assembled with Markdown escapes are intentionally not detected.

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
