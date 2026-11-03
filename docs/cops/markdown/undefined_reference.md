# Markdown/UndefinedReference

Reports undefined full `[text][id]` and collapsed `[id][]` references, including images. Definitions can appear before or after their uses; IDs are matched case-insensitively with collapsed whitespace. Link labels can span lines and contain nested bracket text.

Checking shortcut references can also flag bracketed ordinary prose. Task-list markers and footnotes are not treated as link references.

Code blocks/spans, front matter, HTML tags/comments/raw regions, escaped delimiters, and inline destinations are excluded. Definitions retain original source spelling even though the Markdown AST normalizes references.

The rule is report-only because the destination or intended label cannot be inferred.

## Configuration

```yaml
Markdown/UndefinedReference:
  Enabled: true
  ShortcutSyntax: false # Set true to check unresolved [word] references too.
```

## Example

### Bad

```markdown
[Read the guide][missing]
```

### Good

```markdown
[Read the guide][docs]

[docs]: /guide
```
