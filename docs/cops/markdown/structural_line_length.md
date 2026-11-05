# Markdown/StructuralLineLength

Reports long heading, code-block, and table source lines without rewriting structural content.

Use [Prose/MaxLength](../prose/max_length.md) for paragraph formatting. Structural limits and paragraph formatting are configured independently.

## Configuration

```yaml
Markdown/StructuralLineLength:
  Enabled: false
  Headings: 80 # Positive character count, or false to disable.
  CodeBlocks: false # Positive character count, or false to disable.
  Tables: false # Positive character count, or false to disable; includes delimiter rows.
```

## Example

For this configuration:

```yaml
Markdown/StructuralLineLength:
  Enabled: true
  Headings: 12
```

### Bad

```markdown
# A very long heading
```

### Good

```markdown
# Short
```

## Migrating From 0.1.0

Each structural element now has one setting: a positive character count enables that element and sets its limit, while `false` disables it. The shared `Max` setting and separate enable/value pairs have been removed. RuboCop reports obsolete old keys with migration guidance; replace them with a per-element width.

For example, migrate this configuration:

```yaml
Markdown/StructuralLineLength:
  Max: 80
  Headings: true
  HeadingMax: 120
  CodeBlocks: true
  CodeBlockMax: 100
  Tables: false
```

To this configuration:

```yaml
Markdown/StructuralLineLength:
  Headings: 120
  CodeBlocks: 100
  Tables: false
```

The defaults retain 80-character headings while code blocks and tables remain unchecked.
