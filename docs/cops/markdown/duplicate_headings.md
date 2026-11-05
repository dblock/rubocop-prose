# Markdown/DuplicateHeadings

Reports duplicate heading text within the configured scope. Comparison is case-sensitive text without whitespace normalization, including inline code but ignoring emphasis.

Sibling headings share a parent heading; root headings share a scope. Each new parent starts a fresh scope, even when its text repeats. Report-only: renaming headings can break links.

## Configuration

```yaml
Markdown/DuplicateHeadings:
  Enabled: true
  Scope: siblings # Or document to compare headings across the entire document.
```

## Level-Specific Scopes

`Scope` accepts `document`, `siblings`, or `false` (disable duplicate checks). It also accepts a mapping with a required `Default` and level selectors. Unlisted levels inherit `Default`. Every value accepts the same three choices.

Selectors can be integer levels from 1 through 6, quoted inclusive ranges such as `"4-6"`, or quoted strict comparisons such as `">4"` (levels five and six) and `"<3"` (levels one and two). Overlapping selectors, reversed or empty ranges, missing defaults, and invalid scopes are configuration errors; there is no selector precedence.

For this configuration:

```yaml
Markdown/DuplicateHeadings:
  Scope:
    Default: document
    4: siblings
    5: siblings
    6: siblings
```

Levels one through three require document-wide uniqueness. Deeper headings require uniqueness only among siblings:

```markdown
# Guide

## Services

### Service Overview

#### Details

## Clients

### Client Overview

#### Details
```

Both `Details` headings are allowed because they have different parents. Replacing `Client Overview` with `Service Overview` is reported because level three uses document scope. Repeating `Details` under the same parent is still reported.

Each heading's effective scope determines which earlier headings it is compared against, including headings at other levels or with different configured scopes. This preserves existing cross-level comparison semantics: document scope compares against all earlier headings, while sibling scope compares against earlier headings sharing the same parent, including skipped levels.

To disable checks for deeper headings:

```yaml
Markdown/DuplicateHeadings:
  Scope:
    Default: document
    4: siblings
    ">4": false
```

Alternatively, `"4-6": false` disables levels four through six. Disabled headings still establish parent ancestry and remain available for comparison when a later heading's effective scope checks them; they simply do not receive duplicate diagnostics themselves.

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
