# Markdown/HeadingPunctuation

Reports configured punctuation at the end of rendered heading text, including inline code. Closing heading hashes do not count as punctuation.

Report-only: punctuation may be meaningful.

## Configuration

```yaml
Markdown/HeadingPunctuation:
  Enabled: false
  Punctuation: ".,;:!?" # Forbidden final characters; accepts Unicode. Use '' to disable.
```

## Example

### Bad

```markdown
# Installation!
```

### Good

```markdown
# Installation
```
