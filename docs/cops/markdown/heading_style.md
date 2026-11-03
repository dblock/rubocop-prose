# Markdown/HeadingStyle

Enforces ATX, closed ATX, Setext, or consistent headings. Consistent mode follows the first heading. Setext supports only levels one and two.

Report-only: changing syntax can alter heading levels or surrounding structure.

## Configuration

```yaml
Markdown/HeadingStyle:
  Enabled: false
  EnforcedStyle: consistent # consistent, atx, atx_closed or setext.
```

## Example

For this configuration:

```yaml
Markdown/HeadingStyle:
  Enabled: true
  EnforcedStyle: atx
```

### Bad

```markdown
Title
=====
```

### Good

```markdown
# Title
```
