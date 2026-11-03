# Markdown/DescriptiveLinkText

Reports inline and resolved reference links whose complete rendered label matches a configured generic label. Matching ignores case and collapses whitespace; formatting, code spans, and HTML entities in labels are interpreted before matching.

Prefer a label describing the destination, such as `[the installation guide](https://example.test)`.

Images themselves, angle autolinks, unresolved references, code blocks/spans, front matter, HTML tags/comments/raw regions, and escaped link syntax are excluded. Matching is whole-label, not substring or natural-language analysis; `click here for installation` does not match the default `click here` entry.

The rule is report-only because descriptive text requires human context. This configurable heuristic is not a complete accessibility audit.

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
