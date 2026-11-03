# Prose/UnorderedListMarker

Disabled by default. `EnforcedStyle` is `consistent` (the default), `asterisk`, `plus`, or `dash`. Consistent mode uses the first parsed unordered list marker throughout the document, including nested lists and blockquotes.

Only parsed list items are checked; escaped markers, front matter, thematic breaks, and code are ignored. Corrections replace only the marker; replacements that could create a thematic break are report-only. A different marker per nesting level (`sublist`) is not supported.

## Examples

For this configuration:

```yaml
Prose/UnorderedListMarker:
  Enabled: true
  EnforcedStyle: "dash"
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
