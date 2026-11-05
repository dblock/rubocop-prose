# Markdown/TablePipes

Enforces leading and trailing table pipes. Consistent mode follows each table's header.

Autocorrection preserves cell contents. Removing pipes from single-column tables or empty boundary cells is report-only when it could change the table's meaning.

## Configuration

```yaml
Markdown/TablePipes:
  Enabled: true
  Style: consistent
  SupportedStyles:
    - consistent
    - leading_and_trailing
    - leading_only
    - trailing_only
    - no_leading_or_trailing
```

## Example

For this configuration:

```yaml
Markdown/TablePipes:
  Style: leading_and_trailing
```

### Bad

```markdown
A | B
--- | ---
one | two
```

### Good

```markdown
| A | B |
| --- | --- |
| one | two |
```
