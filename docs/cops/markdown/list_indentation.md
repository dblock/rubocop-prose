# Markdown/ListIndentation

Requires sibling markers to align with the first item in each ordered or unordered list. Nested lists are checked independently; blockquote prefixes do not count toward indentation.

Indentation counts source characters, not tab stops. Report-only: moving a marker could change which content belongs to the item.

## Configuration

```yaml
Markdown/ListIndentation:
  Enabled: true
```

## Example

### Bad

```markdown
- one
 - two
```

### Good

```markdown
- one
- two
```
