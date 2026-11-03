# Prose/OrderedListNumbering

Disabled by default. `EnforcedStyle` is `sequential` (default) or `ones`. Sequential numbering starts at the first number of each parsed list, so lists can start at zero or another number. Ones mode requires every number to be 1. Nested and quoted lists are checked independently.

Corrections preserve punctuation and only replace numbers of equal character width; width-changing offenses are report-only because continuation indentation could change meaning. Automatic style inference and a forced sequential start at 1 are not provided. Code, escaped markers, and front matter are excluded.

## Examples

For this configuration:

```yaml
Prose/OrderedListNumbering:
  Enabled: true
```

### Bad

```markdown
1. one
1. two
```

### Good

```markdown
1. one
2. two
```
