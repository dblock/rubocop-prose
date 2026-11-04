# Front Matter

By default, Markdown checks ignore a leading header opened with `---` and closed with `---` or `...`. Unclosed headers and delimiters elsewhere remain ordinary Markdown.

Set `IgnoreFrontMatter: false` to inspect the header as Markdown, not validate its YAML. RuboCop directives inside metadata remain ignored, and this setting does not change Ruby snippet extraction.

## Example

```yaml
Markdown:
  IgnoreFrontMatter: true
```
