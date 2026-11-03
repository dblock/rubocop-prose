# Markdown/ReferenceDefinitions

Reports reference definitions that are unused or duplicate an earlier definition. All link and image reference forms count as uses, including nested images and shortcut references; IDs are case-insensitive and whitespace-normalized. Duplicate definitions are retained by the source scanner even when the Markdown AST discards them.

A duplicate definition gets one diagnostic, not separate duplicate and unused diagnostics.

Definitions may have angle-delimited destinations and titles on the same or following source line. Code blocks/spans, front matter, HTML tags/comments/raw regions, escaped definition syntax, and footnotes are excluded from reference processing.

The rule is report-only: removing a definition can remove a comment or select a different duplicate destination.

## Configuration

```yaml
Markdown/ReferenceDefinitions:
  Enabled: true
  CheckUnused: false
  CheckDuplicates: true
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
