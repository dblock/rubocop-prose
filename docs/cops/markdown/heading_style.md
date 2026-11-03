# Markdown/HeadingStyle

Disabled by default.

`EnforcedStyle` accepts `consistent` (default, inferred from the first parsed heading), `atx` (`# Title`), `atx_closed` (`# Title #`) or `setext` (underlined headings). All parsed headings, including container headings, are checked.

Combined ATX/Setext style modes are not provided; `setext` intentionally requires Setext syntax for every heading, so a level-three heading cannot satisfy it. Code, escaped markers and front matter are excluded by the parser.

Report-only: syntax conversion may change level, inline parsing or surrounding block structure.

## Examples

For this configuration:

```yaml
Markdown/HeadingStyle:
  Enabled: true
  EnforcedStyle: "atx"
```

### Bad

```markdown
Title
=====
```

### Good

```markdown
# Title
```
