# Markdown/UnorderedListMarker

Consistent mode uses the first parsed unordered list marker throughout the document, including nested lists and blockquotes.

Only parsed list items are checked; escaped markers, front matter, thematic breaks, and code are ignored. Corrections replace only the marker; replacements that could create a thematic break are report-only. A different marker per nesting level (`sublist`) is not supported.

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
