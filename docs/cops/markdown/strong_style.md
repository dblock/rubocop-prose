# Markdown/StrongStyle

Enforces `**`, `__`, or consistent strong emphasis. Consistent mode follows the first span; ordinary emphasis belongs to [Markdown/EmphasisStyle](emphasis_style.md).

Autocorrection preserves content. Intraword asterisks are not changed to underscores when that would remove the formatting.

## Configuration

```yaml
Markdown/StrongStyle:
  Enabled: true
  Style: consistent
  SupportedStyles:
    - consistent
    - asterisk
    - underscore
```

## Example

For this configuration:

```yaml
Markdown/StrongStyle:
  Style: underscore
```

### Bad

```markdown
This is **important**.
```

### Good

```markdown
This is __important__.
```
