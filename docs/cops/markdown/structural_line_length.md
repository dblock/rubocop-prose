# Markdown/StructuralLineLength

Reports long heading, code-block, and table source lines without rewriting structural content.

Use [Prose/MaxLength](../prose/max_length.md) for paragraph formatting. Structural limits and paragraph formatting are configured independently.

## Configuration

```yaml
Markdown/StructuralLineLength:
  Enabled: false
  Max: 80 # Positive character count.
  Headings: true
  HeadingMax: null # Inherit Max.
  CodeBlocks: false
  CodeBlockMax: null # Inherit Max.
  Tables: false # Includes delimiter rows when enabled.
```

## Example

For this configuration:

```yaml
Markdown/StructuralLineLength:
  Enabled: true
  Max: 12
```

### Bad

```markdown
# A very long heading
```

### Good

```markdown
# Short
```
