# Prose/LinkStyle

Disabled by default.

`AllowedLinkStyles` defaults to `['inline', 'reference', 'autolink']`. `AllowedImageStyles` defaults to `['inline', 'reference']`. Configure these lists independently; an empty list prohibits all corresponding syntax.

The value `reference` permits all resolved reference forms. To be more selective, replace it with any of `full_reference`, `collapsed_reference`, and `shortcut_reference`. The value `inline` permits `[text](destination)` or `![alt](destination)`. The link-only value `autolink` permits angle-bracketed scheme URLs and email addresses; bare URLs are handled separately by `Prose/BareUrl`.

Nested images are checked independently of their containing links. Unresolved references, code blocks/spans, front matter, HTML links/comments/raw regions, and escaped delimiters are excluded.

The rule is report-only: converting styles requires choosing and placing definitions or inventing visible labels.

## Examples

For this configuration:

```yaml
Prose/LinkStyle:
  Enabled: true
  AllowedLinkStyles: ["reference", "autolink"]
  AllowedImageStyles: ["inline"]
```

### Bad

```markdown
[Read the guide](/guide)
```

### Good

```markdown
[Read the guide][docs]

[docs]: /guide
```
