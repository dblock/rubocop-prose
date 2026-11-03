# Markdown/DescriptiveLinkText

Enabled by default.

Reports inline and resolved reference links whose complete rendered label matches an entry in `GenericLabels`. Defaults are `click here`, `here`, `link`, and `more`. Matching ignores case and collapses whitespace; formatting, code spans, and HTML entities in labels are interpreted before matching.

Prefer a label describing the destination, such as `[the installation guide](https://example.test)`. Configure `GenericLabels` for the project's language and editorial conventions; an empty list permits every label.

Images themselves, angle autolinks, unresolved references, code blocks/spans, front matter, HTML tags/comments/raw regions, and escaped link syntax are excluded. Matching is whole-label, not substring or natural-language analysis; `click here for installation` does not match the default `click here` entry.

The rule is report-only because descriptive text requires human context. This configurable heuristic is not a complete accessibility audit.

## Examples

For this configuration:

```yaml
Markdown/DescriptiveLinkText:
  Enabled: true
```

### Bad

```markdown
[click here](/guide)
```

### Good

```markdown
[Read the installation guide](/guide)
```
