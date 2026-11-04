# Markdown/UnclosedFencedCodeBlock

Reports fenced code blocks that reach the end of the document without an explicit closing fence. End-of-file termination is valid Markdown, but an explicit closer can prevent later content from being swallowed after an editing mistake.

This cop is report-only and points to the opening fence; it does not guess where a closing fence belongs.

## Configuration

```yaml
Markdown/UnclosedFencedCodeBlock:
  Enabled: true
```

## Example

### Bad

````markdown
```ruby
puts 'hello'
````

### Good

````markdown
```ruby
puts 'hello'
```
````
