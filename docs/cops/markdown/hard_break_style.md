# Markdown/HardBreakStyle

Requires Markdown paragraph hard breaks to use the configured backslash or trailing-space syntax. The default backslash style is enabled automatically.

On files whose line endings cannot be preserved by RuboCop's source buffer, this cop reports style violations without autocorrecting them.

## Configuration

```yaml
Markdown/HardBreakStyle:
  Enabled: true
  Style: backslash # backslash or spaces.
```

## Example

### Bad: trailing spaces

```markdown
First line.  
Second line.
```

### Good: backslash

```markdown
First line.\
Second line.
```

For this configuration:

```yaml
Markdown/HardBreakStyle:
  Style: spaces
```

### Bad: backslash

```markdown
First line.\
Second line.
```

### Good: trailing spaces

```markdown
First line.  
Second line.
```
