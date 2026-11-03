# Markdown/ListMarkerSpacing

Enforces spacing after list markers. A list uses its `Multi` setting if any item spans multiple lines, including nested content; otherwise it uses `Single`. Empty items are ignored.

Autocorrection supports simple one-line items and widths from one to four spaces. Other cases are report-only to preserve item structure.

## Configuration

```yaml
Markdown/ListMarkerSpacing:
  Enabled: true
  UnorderedSingle: 1
  OrderedSingle: 1
  UnorderedMulti: 1
  OrderedMulti: 1
```

## Example

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
