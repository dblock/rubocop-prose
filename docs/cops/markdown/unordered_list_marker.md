# Markdown/UnorderedListMarker

Enforces a configured unordered list marker or follows the first marker in consistent mode, including nested lists and blockquotes.

Autocorrection changes only the marker and is withheld if it could create a thematic break.

## Configuration

```yaml
Markdown/UnorderedListMarker:
  Enabled: true
  EnforcedStyle: consistent # consistent, asterisk, plus or dash.
```

## Example

For this configuration:

```yaml
Markdown/UnorderedListMarker:
  EnforcedStyle: dash
```

### Bad

```markdown
* one
* two
```

### Good

```markdown
- one
- two
```
