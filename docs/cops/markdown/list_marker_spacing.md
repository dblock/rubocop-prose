# Markdown/ListMarkerSpacing

Enforces one spacing policy for all ordered and unordered list items, whether single-line or multiline. Empty items are ignored when checking spacing.

The `fixed` style requires exactly `MinSpaces` after every marker. The `aligned` style uses `MinSpaces` after the widest actual sibling marker and adds padding after shorter markers so item text aligns when sibling markers have the same indentation. For bullets, whose markers are all one character wide, both styles require `MinSpaces`.

Nested lists, separate lists, and lists in different containers are evaluated independently. Empty sibling markers contribute to the width even though their spacing is not checked. Alignment uses source markers, not inferred sequence numbers, and works across wider transitions such as `99.` to `100.`.

Autocorrection supports simple one-line items and computed gaps from one to four spaces. Multiline items, items containing nested blocks, and larger gaps are report-only to preserve continuation indentation and item structure. Tabs in a nonempty marker gap are replaced with spaces when correction is safe.

## Configuration

```yaml
Markdown/ListMarkerSpacing:
  Enabled: true
  Style: fixed
  MinSpaces: 1
```

`Style` accepts `fixed` or `aligned`. `MinSpaces` must be a positive integer. The defaults retain one space after every marker.

## Fixed Spacing

### Bad

```markdown
-  one
-  two
```

### Good

```markdown
- one
- two
```

## Aligned Spacing

For this configuration:

```yaml
Markdown/ListMarkerSpacing:
  Style: aligned
  MinSpaces: 2
```

### Bad

```markdown
8. Eight
9. Nine
10. Ten

- Bullet
```

### Good

```markdown
8.   Eight
9.   Nine
10.  Ten

-  Bullet
```

Each gap is the widest sibling marker width minus the current marker width plus `MinSpaces`. Setting `MinSpaces: 1` produces two spaces after `8.` and `9.` and one after `10.` in this example.

## Migrating From 0.1.0

**Breaking configuration change:** `OrderedSingle`, `OrderedMulti`, `UnorderedSingle`, and `UnorderedMulti` have been removed. RuboCop rejects these keys with migration guidance instead of silently ignoring them.

Replace equal legacy values with `Style: fixed` and that value for `MinSpaces`. For example, four legacy settings all set to `2` become:

```yaml
Markdown/ListMarkerSpacing:
  Style: fixed
  MinSpaces: 2
```

Different legacy values cannot all be preserved by a single policy; choose the desired shared spacing.
