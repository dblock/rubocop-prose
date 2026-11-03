# Markdown/UnorderedListIndentation

Top-level unordered markers start at zero indentation; nested unordered markers use the configured indentation beyond their immediate parent list marker, including ordered parents. Quote prefixes are excluded, and entering a deeper quote container starts a fresh zero-indentation baseline.

This rule is report-only because reindenting a list requires preserving all continuation blocks. It checks parsed unordered items, not marker-shaped code. `start_indented` and `start_indent` modes are not provided, and tabs are measured as source characters rather than expanded tab stops.

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
