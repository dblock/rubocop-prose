# Front matter

`Prose.IgnoreFrontMatter` defaults to `true`. A closed header at the start of a Markdown document, opened with `---` and closed with `---` or `...`, is excluded from prose parsing without altering the source buffer or line numbers. A BOM and CRLF line endings are supported. Non-initial or unclosed delimiters are ordinary Markdown.

Set `Prose: { IgnoreFrontMatter: false }` to inspect header contents as Markdown, not YAML. This shared setting controls prose formatting, syntax diagnostics, and document rules; it does not change another processor's Ruby snippet extraction or implement YAML validation. Hidden RuboCop directives inside metadata remain ignored.

## Examples

Use a boolean, not a quoted string, for `IgnoreFrontMatter`.

### Bad

```yaml
Prose:
  IgnoreFrontMatter: "true"
```

### Good

```yaml
Prose:
  IgnoreFrontMatter: true
```
