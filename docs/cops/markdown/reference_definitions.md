# Markdown/ReferenceDefinitions

Reports duplicate reference definitions and, when enabled, unused definitions. All link and image reference forms count as uses; IDs ignore case and repeated whitespace. Footnotes are not checked.

Report-only: removing definitions can change link targets or remove comments.

## Configuration

```yaml
Markdown/ReferenceDefinitions:
  Enabled: true
  CheckUnused: false
  CheckDuplicates: true
  IgnoredDefinitions: # Allow conventional comment-like definitions, using normalized IDs.
    - "//"
```

## Example

### Bad

```markdown
[docs]: /guide
[docs]: /another-guide
```

### Good

```markdown
[Read the guide][docs]

[docs]: /guide
```
