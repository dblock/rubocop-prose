# Markdown/UnorderedListIndentation

Requires top-level unordered markers at zero indentation and nested markers at the configured offset from their parent, including ordered parents. A deeper blockquote starts a fresh baseline.

Indentation counts source characters, not tab stops. Report-only: moving a list can change its continuation blocks.

## Configuration

```yaml
Markdown/UnorderedListIndentation:
  Enabled: true
  Indent: 2 # Characters beyond the immediate parent list marker.
```

## Example

### Bad

```markdown
- Parent
   - Child
```

### Good

```markdown
- Parent
  - Child
```
