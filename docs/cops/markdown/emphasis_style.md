# Markdown/EmphasisStyle

Enforces a configured emphasis delimiter or follows the first one in consistent mode. Strong emphasis belongs to [Markdown/StrongStyle](strong_style.md).

Autocorrection preserves content. Intraword asterisks are not changed to underscores when that would remove the emphasis.

## Configuration

```yaml
Markdown/EmphasisStyle:
  Enabled: true
  Style: consistent # consistent, asterisk or underscore.
```

## Example

For this configuration:

```yaml
Markdown/EmphasisStyle:
  Style: underscore
```

### Bad

```markdown
This is *important*.
```

### Good

```markdown
This is _important_.
```
