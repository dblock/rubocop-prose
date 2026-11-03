# Markdown/LinkStyle

Link and image styles are configured independently.

The value `reference` permits all resolved reference forms. To be more selective, replace it with any of `full_reference`, `collapsed_reference`, and `shortcut_reference`. The value `inline` permits `[text](destination)` or `![alt](destination)`. The link-only value `autolink` permits angle-bracketed scheme URLs and email addresses; bare URLs are handled separately by [Markdown/BareUrl](bare_url.md).

Nested images are checked independently of their containing links. Unresolved references, code blocks/spans, front matter, HTML links/comments/raw regions, and escaped delimiters are excluded.

The rule is report-only: converting styles requires choosing and placing definitions or inventing visible labels.

## Configuration

```yaml
Markdown/LinkStyle:
  Enabled: false
  AllowedLinkStyles: # An empty list prohibits all link syntax.
    - inline
    - reference
    - autolink
  AllowedImageStyles: # An empty list prohibits all image syntax.
    - inline
    - reference
```

## Example

For this configuration:

```yaml
Markdown/LinkStyle:
  Enabled: true
  AllowedLinkStyles:
    - reference
    - autolink
  AllowedImageStyles:
    - inline
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
