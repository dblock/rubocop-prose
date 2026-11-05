# Markdown/ReferenceDefinitions

Reports duplicate reference definitions and, when enabled, unused definitions. All link and image reference forms count as uses; IDs ignore case and repeated whitespace. Footnotes are not checked.

`Duplicates: forbid` reports every duplicate, including identical definitions. Set `Duplicates: allow_identical` to repeat definitions near their uses while still reporting conflicts. Destinations are compared after decoding Markdown escapes and HTML entities; titles must match exactly. The first definition still determines the link target. `Duplicates: allow` permits all duplicates.

Set `Unused: true` to report unused definitions independently of the duplicate policy, including when `Duplicates: allow`. When a definition is both a forbidden duplicate and unused, only the duplicate diagnostic is reported for that definition. `IgnoredDefinitions` exempts normalized IDs from both checks.

Report-only: removing definitions can change link targets or remove comments.

## Configuration

```yaml
Markdown/ReferenceDefinitions:
  Enabled: true
  Duplicates: forbid # forbid, allow_identical, or allow
  Unused: false
  IgnoredDefinitions: # Allow conventional comment-like definitions, using normalized IDs.
    - "//"
```

## Example

### Bad

```markdown
[docs]: /guide
[docs]: /another-guide
```

### Good

```markdown
[Read the guide][docs]

[docs]: /guide
```

## Migrating From 0.1.0

Rename `CheckUnused` to `Unused`, keeping its value. Replace `CheckDuplicates` and `AllowIdenticalDuplicates` with `Duplicates`:

- `CheckDuplicates: false`, regardless of `AllowIdenticalDuplicates`: use `Duplicates: allow`.
- `CheckDuplicates: true` (or omitted) with `AllowIdenticalDuplicates: true`: use `Duplicates: allow_identical`.
- `CheckDuplicates: true` (or omitted) with `AllowIdenticalDuplicates: false` (or omitted): use `Duplicates: forbid` (the default).

For example, replace:

```yaml
Markdown/ReferenceDefinitions:
  CheckDuplicates: true
  AllowIdenticalDuplicates: true
  CheckUnused: true
```

With:

```yaml
Markdown/ReferenceDefinitions:
  Duplicates: allow_identical
  Unused: true
```
