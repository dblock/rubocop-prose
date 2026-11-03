# Markdown/FenceBlankLines

Adds blank lines around fenced code blocks, preserving list and blockquote nesting. Document boundaries and a preceding front-matter header do not require extra padding.

A fence on a list marker's own line does not require a blank before it.

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
