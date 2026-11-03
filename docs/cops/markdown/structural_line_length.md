# Markdown/StructuralLineLength

Disabled by default. Reports long heading, code-block, and table source lines without rewriting structural content. `Max` is a positive character count, default `80`. `Headings` defaults to `true`; `CodeBlocks` and `Tables` default to `false`. `HeadingMax` and `CodeBlockMax` optionally override `Max`; `null` inherits it. Table delimiter rows count as source lines.

This cop does not inspect `.txt` or reflow prose paragraphs. Use `Prose/MaxLength` for paragraph formatting. Both cops have independent configuration, so structural limits can remain enabled while paragraphs use `Max: false`.

## Examples

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
