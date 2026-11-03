# Prose/Syntax

Opt-in native Kramdown GFM parser diagnostics. Warnings are reported through normal RuboCop formatters at their original source lines, with an EOF diagnostic clamped to the last actual line. No autocorrection or YAML validation is attempted.

The diagnostic set follows the parser, not a CommonMark conformance validator. If `Prose/UndefinedReference` or `Prose/ReferenceDefinitions` is enabled, its corresponding reference diagnostics are left to that specialized cop to avoid duplicate reports.

## Examples

For this configuration:

```yaml
Prose/Syntax:
  Enabled: true
```

### Bad

```markdown
[Read the guide][missing]
```

### Good

```markdown
[Read the guide][docs]

[docs]: /guide
```
