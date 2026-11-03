# Markdown/BlockquoteSpacing

Enabled by default. Multiple spaces or tabs after a blockquote marker are replaced with one space. Nested quote markers are checked separately. Missing spaces are not reported.

Code and front matter are excluded. Indentation after the innermost quote marker within a parsed list is deliberately preserved, as are empty quote lines; those spaces can carry list structure. This rule does not attempt to distinguish superfluous spacing from required list indentation inside list items.

## Examples

For this configuration:

```yaml
Markdown/BlockquoteSpacing:
  Enabled: true
```

### Bad

```markdown
>  A quotation.
```

### Good

```markdown
> A quotation.
```
