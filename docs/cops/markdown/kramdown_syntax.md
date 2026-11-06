# Markdown/KramdownSyntax

Reports Kramdown GFM parsing warnings through RuboCop. Report-only.

Reference warnings are handled by [Markdown/UndefinedReference](undefined_reference.md) and [Markdown/ReferenceDefinitions](reference_definitions.md) when enabled, avoiding duplicate reports.

## Configuration

```yaml
Markdown/KramdownSyntax:
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

## Migrating From 0.1.0

Rename this plugin's `Markdown/Syntax` configuration to `Markdown/KramdownSyntax`. When using RuboCop-md 3.0.0 or newer, `Markdown/Syntax` configures its separate cop; leave that disabled to avoid duplicate parser warnings.
