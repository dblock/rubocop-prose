# Markdown/Syntax

Reports Kramdown GFM parsing warnings through RuboCop. Report-only.

Reference warnings are handled by [Markdown/UndefinedReference](undefined_reference.md) and [Markdown/ReferenceDefinitions](reference_definitions.md) when enabled, avoiding duplicate reports.

## Configuration

```yaml
Markdown/Syntax:
  Enabled: true
```

## Example

### Bad

```markdown
[Read the guide][missing]
```

### Good

```markdown
[Read the guide][docs]

[docs]: /guide
```
