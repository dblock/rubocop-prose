# Markdown/ClosedHeadingSpacing

Replaces multiple spaces or tabs before closing heading hashes with one space, leaving the hashes intact. A single separating tab is accepted.

## Configuration

```yaml
Markdown/ClosedHeadingSpacing:
  Enabled: true
```

## Example

### Bad

```markdown
# Title  #
```

### Good

```markdown
# Title #
```
