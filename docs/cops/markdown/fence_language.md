# Markdown/FenceLanguage

Requires a language on fenced code blocks, optionally restricted by an allowlist or a disallowlist. Names are case-sensitive; configure only one list.

Use `DisallowedLanguages` to reject selected names while accepting all other nonempty languages.

Report-only: specify the appropriate language.

## Configuration

```yaml
Markdown/FenceLanguage:
  Enabled: true
  AllowedLanguages: [] # Accept any nonempty language; otherwise allow only listed, case-sensitive names.
  DisallowedLanguages: [] # Reject only listed names; cannot be combined with a nonempty AllowedLanguages.
```

## Example

For this configuration:

```yaml
Markdown/FenceLanguage:
  DisallowedLanguages:
    - js
```

### Bad

````markdown
```js
console.log('hello')
```
````

### Good

````markdown
```javascript
console.log('hello')
```
````
