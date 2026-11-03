# Markdown/FenceLanguage

Every parsed fenced code block must specify a language. Nested list and quote fences are included; indented code and front matter are ignored.

This rule is report-only because the language cannot safely be inferred. Language aliases are not normalized and a separate language-only information-string mode is not provided. Language metadata is read from the parser, not guessed from raw fence-looking text; only fence syntax recognized by the configured Markdown parser is checked.

## Configuration

```yaml
Markdown/FenceLanguage:
  Enabled: true
  AllowedLanguages: [] # Accept any nonempty language; otherwise allow only listed, case-sensitive names.
```

## Example

### Bad

````markdown
```
puts 1
```
````

### Good

````markdown
```ruby
puts 1
```
````
