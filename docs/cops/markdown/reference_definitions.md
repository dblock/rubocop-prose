# Markdown/ReferenceDefinitions

Disabled by default.

Reports reference definitions that are unused or duplicate an earlier definition. All link and image reference forms count as uses, including nested images and shortcut references; IDs are case-insensitive and whitespace-normalized. Duplicate definitions are retained by the source scanner even when the Markdown AST discards them.

`CheckUnused` and `CheckDuplicates` both default to `true`. `IgnoredDefinitions` defaults to `['//']`, permitting the conventional comment-like definition; its entries use the same normalized ID matching. A duplicate definition gets one diagnostic, not separate duplicate and unused diagnostics.

Definitions may have angle-delimited destinations and titles on the same or following source line. Code blocks/spans, front matter, HTML tags/comments/raw regions, escaped definition syntax, and footnotes are excluded from reference processing.

The rule is report-only: removing a definition can remove a comment or select a different duplicate destination.

## Examples

For this configuration:

```yaml
Markdown/ReferenceDefinitions:
  Enabled: true
```

### Bad

```markdown
[unused]: /guide
```

### Good

```markdown
[Read the guide][docs]

[docs]: /guide
```
