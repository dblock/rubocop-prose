# Markdown/HeadingIndentation

Enabled by default.

Reports headings whose physical source line begins with spaces or tabs. In addition to already parsed headings, one-to-three-space-indented candidates are reparsed without indentation because the project's parser does not normally recognize them. ATX and Setext headings are included, but indented code, fenced code, escaped markers and front matter are not headings.

Indentation is measured before the outermost container marker, not after blockquote or list prefixes; for example `> # Title` is accepted. Setext underline indentation is not checked independently.

Report-only: dedenting can move a heading out of a container or change block structure.

## Examples

For this configuration:

```yaml
Markdown/HeadingIndentation:
  Enabled: true
```

### Bad

```markdown
 # Title
```

### Good

```markdown
# Title
```
