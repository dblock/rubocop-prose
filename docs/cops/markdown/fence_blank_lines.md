# Markdown/FenceBlankLines

Parsed fenced code blocks require blank lines before and after adjacent content. File boundaries and a preceding front-matter closing line are accepted. Corrections insert container-aware blank lines, deduplicating boundaries shared by adjacent fences.

An opening fence on the list marker's own line never requires a blank before that line. This avoids detaching the fence from its list item. Indented code is ignored.

## Configuration

```yaml
Markdown/FenceBlankLines:
  Enabled: true
  ListItems: true # Set false to skip fences inside list items.
```

## Example

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
