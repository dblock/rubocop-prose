# Prose/FenceStyle

Disabled by default. `EnforcedStyle` is `backtick`, `tilde`, or `consistent` (default). Consistent mode adopts the first parsed fence's delimiter throughout the document. Indented code and front matter are ignored.

Corrections replace opening and closing delimiters together, preserve language metadata and container prefixes, and lengthen the new fence if needed to avoid delimiter runs in its content. A conversion to backticks with backticks in the information string is report-only. This rule does not enforce an exact fence length or normalize language information; only parsed, source-mappable fence pairs are checked.

## Examples

For this configuration:

```yaml
Prose/FenceStyle:
  Enabled: true
  EnforcedStyle: "backtick"
```

### Bad

```markdown
~~~ruby
puts 1
~~~
```

### Good

````markdown
```ruby
puts 1
```
````
