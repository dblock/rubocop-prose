# Markdown/DescriptiveLinkText

Reports links whose entire rendered label matches a configured generic label, ignoring case and repeated whitespace. Prefer descriptive text such as `[the installation guide](https://example.test)`.

Matching is whole-label: `click here for installation` does not match `click here`. Images and autolinks are not checked. Report-only.

## Configuration

```yaml
Markdown/DescriptiveLinkText:
  Enabled: true
  GenericLabels: # Customize for the project's language; an empty list permits every label.
    - click here
    - here
    - link
    - more
```

## Example

### Bad

```markdown
[click here](/guide)
```

### Good

```markdown
[Read the installation guide](/guide)
```
