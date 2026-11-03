# Markdown/ThematicBreakStyle

Enforces a configured thematic break or follows the first break's exact spelling in consistent mode. Autocorrection preserves indentation and blockquote nesting.

## Configuration

```yaml
Markdown/ThematicBreakStyle:
  Enabled: true
  Style: consistent # consistent or a literal valid thematic break, such as ---, *** or * * *.
```

## Example

For this configuration:

```yaml
Markdown/ThematicBreakStyle:
  Style: "* * *"
```

### Bad

```markdown
Text.

---
```

### Good

```markdown
Text.

* * *
```
