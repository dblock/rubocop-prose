# Markdown/UnorderedListIndentation

Enabled by default. `Indent` defaults to 2. Top-level unordered markers start at zero indentation; nested unordered markers are indented by `Indent` characters beyond their immediate parent list marker, including ordered parents. Quote prefixes are excluded, and entering a deeper quote container starts a fresh zero-indentation baseline.

This rule is report-only because reindenting a list requires preserving all continuation blocks. It checks parsed unordered items, not marker-shaped code. `start_indented` and `start_indent` modes are not provided, and tabs are measured as source characters rather than expanded tab stops.

## Examples

For this configuration:

```yaml
Markdown/UnorderedListIndentation:
  Enabled: true
```

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
