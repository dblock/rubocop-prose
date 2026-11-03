# Markdown/ListBlankLines

Adds blank lines around lists, preserving blockquote nesting. Document boundaries and a preceding front-matter header do not require padding.

Nested lists need no separation from their parent items. Continuation text within an item is not content after the list.

## Configuration

```yaml
Markdown/ListBlankLines:
  Enabled: true
```

## Example

### Bad

```markdown
# Items
- one
- two
```

### Good

```markdown
# Items

- one
- two
```
