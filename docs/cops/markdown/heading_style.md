# Markdown/HeadingStyle

Enforces ATX, closed ATX, Setext, or consistent headings. Consistent mode follows the first heading. Setext supports only levels one and two.

Report-only: changing syntax can alter heading levels or surrounding structure.

## Configuration

```yaml
Markdown/HeadingStyle:
  Enabled: false
  Style: consistent # consistent, atx, atx_closed or setext.
```

## Example

For this configuration:

```yaml
Markdown/HeadingStyle:
  Enabled: true
  Style: atx
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

## Migrating From 0.1.0

Replace `EnforcedStyle` with `Style`:

```yaml
Markdown/HeadingStyle:
  Style: atx
```
