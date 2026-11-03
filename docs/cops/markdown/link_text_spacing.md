# Markdown/LinkTextSpacing

Enabled by default.

Reports leading or trailing whitespace inside the visible label of an inline or resolved reference link. Nested bracket text and labels spanning source lines are supported. Images, autolinks, unresolved references, and zero-length labels are not checked.

Autocorrection replaces only the label with its trimmed spelling, preserving the destination, title, explicit reference ID, and original source coordinates. Normalized collapsed and shortcut reference identities are unchanged; corrections are idempotent.

Code blocks/spans, front matter, HTML tags/comments/raw regions, and escaped delimiters are excluded. Whitespace-only labels are reported without correction rather than turning a link into different syntax.

## Examples

For this configuration:

```yaml
Markdown/LinkTextSpacing:
  Enabled: true
```

### Bad

```markdown
[ guide ](/guide)
```

### Good

```markdown
[guide](/guide)
```
