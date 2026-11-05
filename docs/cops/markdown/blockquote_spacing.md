# Markdown/BlockquoteSpacing

Requires one space after each nonempty blockquote marker, including nested markers, and replaces multiple spaces or tabs with one space. This cop is enabled by default.

Empty quote lines and indentation inside quoted lists and code are preserved. Missing separators are autocorrected only when reparsing confirms the Markdown structure is unchanged; otherwise, the offense is report-only.

[Markdown/TrailingWhitespace](trailing_whitespace.md) independently trims trailing whitespace on empty quote lines; its opt-in `AllowEmptyBlockquoteSpace` permits one trailing space.

## Configuration

```yaml
Markdown/BlockquoteSpacing:
  Enabled: true
```

## Example

### Bad

```markdown
>A quotation.
>  A quotation.
>>A nested quotation.
```

### Good

```markdown
> A quotation.
> A quotation.
> > A nested quotation.
```
