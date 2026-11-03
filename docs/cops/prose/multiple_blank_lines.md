# Prose/MultipleBlankLines

Enabled by default. Consecutive blank-line limits for Markdown and plain text. Markdown code blocks and ignored metadata are excluded; `.txt` has no such syntax or exemptions. `Max` is a non-negative integer, default `1`. Excess blank lines are safely removed while retaining paragraph separation.

`Max: 0` is report-only: deleting all paragraph separators changes Markdown structure. Blank blockquote markers are handled by the dedicated blockquote rule rather than counted as empty lines here.

## Examples

For this configuration:

```yaml
Prose/MultipleBlankLines:
  Enabled: true
```

### Bad

```markdown
First paragraph.


Second paragraph.
```

### Good

```markdown
First paragraph.

Second paragraph.
```
