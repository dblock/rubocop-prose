# Markdown/LinkStyle

Restricts link and image styles independently, including images nested in links.

Use `inline`, `reference`, or individual reference forms: `full_reference`, `collapsed_reference`, and `shortcut_reference`. Links also support `autolink` for angle-bracketed URLs and email addresses. Bare URLs belong to [Markdown/BareUrl](bare_url.md).

Report-only: changing styles may require new labels or definitions.

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
