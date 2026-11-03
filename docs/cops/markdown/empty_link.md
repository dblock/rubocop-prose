# Markdown/EmptyLink

Disabled by default.

Reports Markdown links whose decoded destination is empty or exactly `#`, including angle-delimited empty destinations, optional titles, and links resolved through empty reference definitions. An empty visible label with a real destination is not an empty destination.

Images, unresolved references, code blocks/spans, front matter, HTML tags/comments/raw regions, and escaped delimiters are excluded. This rule does not fetch files or URLs and makes no judgment about a nonempty destination's existence.

The rule is report-only because the intended destination cannot be inferred.

## Examples

For this configuration:

```yaml
Markdown/EmptyLink:
  Enabled: true
```

### Bad

```markdown
[Read the guide]()
```

### Good

```markdown
[Read the guide](/guide)
```
