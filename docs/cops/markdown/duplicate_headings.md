# Markdown/DuplicateHeadings

Reports duplicate heading text within the configured scope. Comparison is case-sensitive text without whitespace normalization, including inline code but ignoring emphasis.

Sibling headings share a parent heading; root headings share a scope. Each new parent starts a fresh scope, even when its text repeats. Report-only: renaming headings can break links.

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
