# Front matter

`Markdown/IgnoreFrontMatter` defaults to `true`. A closed header at the start of a Markdown document, opened with `---` and closed with `---` or `...`, is excluded from prose parsing without altering the source buffer or line numbers. A BOM and CRLF line endings are supported. Non-initial or unclosed delimiters are ordinary Markdown. This setting never affects `.txt`, where delimiters and metadata-looking content are literal.

Set `Markdown: { IgnoreFrontMatter: false }` to inspect header contents as Markdown, not YAML. This setting controls prose formatting, syntax diagnostics, and document rules for Markdown; it does not change another processor's Ruby snippet extraction or implement YAML validation. Hidden RuboCop directives inside metadata remain ignored. Other `Markdown:` settings are preserved for their owning processor.

## Example

Use a boolean, not a quoted string, for `IgnoreFrontMatter`.

```yaml
Markdown:
  IgnoreFrontMatter: true
```
