# Markdown/UnorderedListIndentation

Requires top-level unordered markers at zero indentation and nested markers at the configured offset from their parent. Under an ordered parent, the offset is at least the width of the parent's marker and following spacing, so the child can align with its content. A deeper blockquote starts a fresh baseline.

Indentation counts source characters, not tab stops. Report-only: moving a list can change its continuation blocks.

## Configuration

```yaml
Markdown/UnorderedListIndentation:
  Enabled: true
  Indent: 2 # Characters beyond the parent marker, or its content offset if wider and ordered.
```

## Example

### Bad

```markdown
- Parent
   - Child

1. Ordered parent

    - Child

10. Wider ordered parent

     - Child
```

### Good

```markdown
- Parent
  - Child

1. Ordered parent

   - Child

10. Wider ordered parent

    - Child
```
