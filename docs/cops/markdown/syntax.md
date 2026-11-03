# Markdown/Syntax

Native Kramdown GFM parser diagnostics. Warnings are reported through normal RuboCop formatters at their original source lines, with an EOF diagnostic clamped to the last actual line. No autocorrection or YAML validation is attempted.

The diagnostic set follows the parser, not a CommonMark conformance validator. If [Markdown/UndefinedReference](undefined_reference.md) or [Markdown/ReferenceDefinitions](reference_definitions.md) is enabled, its corresponding reference diagnostics are left to that specialized cop to avoid duplicate reports.

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
