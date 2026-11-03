# Markdown/BlockquoteSpacing

Replaces multiple spaces or tabs after blockquote markers with one space, including nested markers. Missing spaces are not reported.

Empty quote lines and indentation inside quoted lists are preserved because those spaces can carry structure.

## Configuration

```yaml
Markdown/BlockquoteSpacing:
  Enabled: true
```

## Example

### Bad

```markdown
>  A quotation.
```

### Good

```markdown
> A quotation.
```
