# Markdown/UndefinedReference

Reports undefined full `[text][id]` and collapsed `[id][]` link or image references. Definitions can appear anywhere; IDs ignore case and repeated whitespace.

Optional shortcut checking may flag ordinary bracketed prose. Task-list markers and footnotes are not references. Report-only.

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
