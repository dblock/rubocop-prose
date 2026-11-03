# Markdown/FenceBlankLines

Enabled by default. Parsed fenced code blocks require blank lines before and after adjacent content. File boundaries and a preceding front-matter closing line are accepted. Corrections insert container-aware blank lines, deduplicating boundaries shared by adjacent fences.

`ListItems` defaults to true; set it to false to skip fences anywhere inside list items. An opening fence on the list marker's own line never requires a blank before that line. This avoids detaching the fence from its list item. Indented code is ignored.

## Examples

For this configuration:

```yaml
Markdown/FenceBlankLines:
  Enabled: true
```

### Bad

````markdown
Example:
```ruby
puts 1
```
More text.
````

### Good

````markdown
Example:

```ruby
puts 1
```

More text.
````
