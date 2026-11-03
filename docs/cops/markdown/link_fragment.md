# Markdown/LinkFragment

Checks links beginning with `#` against headings and explicit anchors in the same document. Matching is case-sensitive and decodes entities and percent escapes; `+` stays literal.

`Renderer` selects approximate GitHub, GitLab, or Kramdown heading IDs. GitLab collapses repeated hyphens; Kramdown uses ASCII IDs. Duplicate headings receive numbered suffixes. Explicit heading IDs, HTML `id` attributes, and HTML anchor `name` attributes are accepted.

Report-only. Page-top links are configured independently of [Markdown/EmptyLink](empty_link.md).

## Configuration

```yaml
Markdown/LinkFragment:
  Enabled: false
  Renderer: github # Also supports gitlab and kramdown.
  AdditionalAnchors: [] # Case-sensitive IDs supplied by the site's renderer or template.
  AllowEmptyFragment: true # Allow # as a page-top link.
```

## Example

### Bad

```markdown
# Installation

[Install](#missing)
```

### Good

```markdown
# Installation

[Install](#installation)
```
