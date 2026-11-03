# Markdown/HeadingPunctuation

Checks the final non-whitespace character of parsed heading plain text, including inline-code text and excluding closing heading hashes. Unlike a source-regex implementation, inline emphasis and links are interpreted by the parser; punctuation escaped in Markdown still appears in the rendered text and is checked. Code blocks and front matter are excluded.

Report-only: punctuation can be meaningful, including in code or identifiers.

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
