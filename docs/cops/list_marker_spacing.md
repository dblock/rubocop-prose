# Prose/ListMarkerSpacing

Disabled by default. `UnorderedSingle`, `OrderedSingle`, `UnorderedMulti`, and `OrderedMulti` default to 1 space. A list uses its Multi setting if any item spans multiple source lines, including nested content; otherwise it uses Single. Empty items are ignored.

Only parsed list markers are checked. Simple one-line paragraph items can be corrected; multiline items and items beginning with block syntax are report-only to avoid changing content indentation or parsing. Multiline classification follows parsed source spans rather than list looseness alone. Configured correction widths must be between 1 and 4; other widths are report-only.

## Examples

For this configuration:

```yaml
Prose/ListMarkerSpacing:
  Enabled: true
```

### Bad

```markdown
-  one
-  two
```

### Good

```markdown
- one
- two
```
