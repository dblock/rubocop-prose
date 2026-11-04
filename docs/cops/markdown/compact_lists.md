# Markdown/CompactLists

Reports blank lines between sibling list items. Blank lines inside an item are not affected. Corrections remove the separator only when both adjacent items consist of a single paragraph; separators next to complex items are reported without correction.

## Configuration

```yaml
Markdown/CompactLists:
  Enabled: true
```

## Example

### Bad

```markdown
- First item.

- Second item.
```

### Good

```markdown
- First item.
- Second item.
```

Blank lines separating paragraphs, nested lists, or code within an item remain in place.
