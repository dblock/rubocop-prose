# Markdown/HeadingStructure

Requires an exact heading outline, in order. Write each entry as one to six hashes, a space, and the expected heading text; ATX and Setext headings are equivalent when their level and text match.

Missing, extra, and mismatched headings are reported without correction.

## Configuration

```yaml
Markdown/HeadingStructure:
  Enabled: false
  Headings: [] # Exact ordered outline; an empty list disables checks.
```

## Example

For this configuration:

```yaml
Markdown/HeadingStructure:
  Enabled: true
  Headings:
    - "# Guide"
    - "## Usage"
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
