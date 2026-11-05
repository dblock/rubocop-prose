# Markdown/FenceStyle

Enforces backtick, tilde, or consistent code fences. Consistent mode follows the first fence.

Autocorrection preserves contents, language metadata, and nesting. Conversion to backticks is report-only if the information string contains backticks.

## Configuration

```yaml
Markdown/FenceStyle:
  Enabled: true
  Style: consistent # consistent, backtick or tilde.
```

## Example

For this configuration:

```yaml
Markdown/FenceStyle:
  Style: backtick
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

## Migrating From 0.1.0

Replace `EnforcedStyle` with `Style`:

```yaml
Markdown/FenceStyle:
  Style: backtick
```
