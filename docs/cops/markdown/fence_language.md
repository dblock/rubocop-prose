# Markdown/FenceLanguage

Requires a language on fenced code blocks, optionally restricted to an allowlist. Names are case-sensitive.

Report-only: specify the appropriate language.

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
