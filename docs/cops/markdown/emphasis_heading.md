# Markdown/EmphasisHeading

Disabled by default.

Reports a single-line parsed paragraph consisting entirely of one emphasis or strong-emphasis element, such as `**Overview**`; ordinary mixed prose, multiline emphasis, escaped emphasis markers and actual headings are accepted.

Terminal punctuation does not exempt the paragraph. Parsed list-item and blockquote paragraphs also participate. Code blocks, front matter and paragraphs consisting only of HTML are excluded by the parser.

Report-only: an emphasis-only paragraph may be intentional, and its intended heading level cannot be inferred safely.

## Examples

For this configuration:

```yaml
Markdown/EmphasisHeading:
  Enabled: true
```

### Bad

```markdown
*Installation*
```

### Good

```markdown
## Installation
```
