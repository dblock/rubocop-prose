# Markdown/HeadingStructure

Disabled by default.

`Headings` specifies an exact ordered outline as strings such as `['# Title', '## Usage', '## License']`. An empty list disables checks. Each entry must contain one to six hashes, one space and the exact expected parsed plain text.

Every parsed heading must match the corresponding configured level and text; unexpected or mismatched headings are reported at their lines, and a missing suffix is reported at end of file. ATX and Setext syntax are interchangeable when level and text match; code and front matter do not participate.

Wildcards, optional headings and arbitrary-heading placeholders are not supported. Report-only: generating, deleting or reordering headings would alter content and structure.

## Examples

For this configuration:

```yaml
Markdown/HeadingStructure:
  Enabled: true
  Headings: ["# Guide", "## Usage"]
```

### Bad

```markdown
# Guide

## Installation
```

### Good

```markdown
# Guide

## Usage
```
