# Markdown/UndefinedReference

Enabled by default.

Reports undefined full `[text][id]` and collapsed `[id][]` references, including images. Definitions can appear before or after their uses; IDs are matched case-insensitively with collapsed whitespace. Link labels can span lines and contain nested bracket text.

`ShortcutSyntax` defaults to `false` because an unresolved `[word]` can be ordinary prose. Set it to `true` to check shortcut references as well; this intentionally also flags bracketed ordinary prose that looks like a shortcut. Task-list markers and footnotes are not treated as link references.

Code blocks/spans, front matter, HTML tags/comments/raw regions, escaped delimiters, and inline destinations are excluded. Definitions retain original source spelling even though the Markdown AST normalizes references.

The rule is report-only because the destination or intended label cannot be inferred.

## Examples

For this configuration:

```yaml
Markdown/UndefinedReference:
  Enabled: true
```

### Bad

```markdown
[Read the guide][missing]
```

### Good

```markdown
[Read the guide][docs]

[docs]: /guide
```
