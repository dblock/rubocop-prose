# Markdown/RawHtml

Reports HTML elements outside the configured allowlist, including nested elements and table cells. Only opening tags are checked; comments are ignored.

Report-only: removing HTML can discard content or structure.

## Configuration

```yaml
Markdown/RawHtml:
  Enabled: false
  AllowedElements: [] # Case-insensitive element names without angle brackets.
```

## Example

### Bad

```markdown
<b>Important</b>
```

### Good

```markdown
**Important**
```
