# Markdown/DuplicateHeadings

Sibling headings have the same nearest preceding lower-level heading. Root headings share a scope, and a new parent heading starts a new scope even if its text repeats.

Comparison is case-sensitive parsed plain text, including inline-code text but ignoring emphasis markers; no slug generation, case folding or whitespace normalization is performed. ATX and Setext headings participate; code and front matter do not.

Report-only: renaming headings can break links and alter meaning.

## Configuration

```yaml
Markdown/DuplicateHeadings:
  Enabled: true
  Scope: siblings # Or document to compare headings across the entire document.
```

## Example

### Bad

```markdown
# Guide

## Usage

## Usage
```

### Good

```markdown
# Guide

## Usage

## License
```
