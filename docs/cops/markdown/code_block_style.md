# Markdown/CodeBlockStyle

Enforces fenced, indented, or consistent code blocks, including nested blocks. Consistent mode follows the first block.

Autocorrection is limited to standalone root-level blocks with blank boundaries. Blocks with metadata, nested containers, empty fenced bodies, or leading/trailing blank content are report-only. Adjacent code blocks are not converted to indentation, to avoid merging them.

## Configuration

```yaml
Markdown/CodeBlockStyle:
  Enabled: false
  EnforcedStyle: consistent # consistent, fenced or indented.
```

## Example

For this configuration:

```yaml
Markdown/CodeBlockStyle:
  Enabled: true
  EnforcedStyle: fenced
```

### Bad

```markdown
    puts 'hello'
```

### Good

````markdown
```ruby
puts 'hello'
```
````
