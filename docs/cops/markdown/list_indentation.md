# Markdown/ListIndentation

Sibling markers in each parsed ordered or unordered list must align with the first sibling. Nested lists are compared independently, and blockquote prefixes are excluded from indentation.

This rule is report-only: moving a marker alone could change the ownership of continuation paragraphs, nested lists, or code. Only siblings recognized by the Markdown parser are compared; lines parsed as code or a different list are not inferred to be misindented siblings. Indentation is measured in source characters, not expanded tab stops.

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
