# Markdown/BlockquoteBlankLines

Enabled by default. Blank lines between adjacent parsed blockquotes in the same container must retain quote markers. Corrections add the next blockquote's prefix, preserving outer quote levels and indentation. Multiple intervening blank lines are checked individually.

Quotes separated by other content and quote-shaped code are ignored. Adjacency follows the parsed block structure. This rule intentionally treats adjacent quotes as one intended quotation; separate them with content if they should remain distinct.

## Examples

For this configuration:

```yaml
Markdown/BlockquoteBlankLines:
  Enabled: true
```

### Bad

```markdown
> First paragraph.

> Second paragraph.
```

### Good

```markdown
> First paragraph.
>
> Second paragraph.
```
