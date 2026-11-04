# Markdown/ListItemCapitalization

Checks capitalization in ordered and unordered list items. `EnforcedStyle` supports `consistent` (default), `initial_capital`, and `title_case`. The word settings follow [Markdown/HeadingCapitalization](heading_capitalization.md).

In `consistent` mode, the first eligible item establishes uppercase or lowercase initials; nested and separate lists establish their own style. `initial_capital` requires uppercase initials regardless of sibling style. Both inspect only the initial prose word, including emphasis or link labels and optional task checkboxes. They skip items beginning with code, images, HTML, entities, numbers, punctuation, uncased letters, paths, URLs, or ambiguous identifiers. They do not search later in an item for prose.

`title_case` checks the first paragraph of each item, capitalizing major words and keeping internal `MinorWords` lowercase. First and last words require capitals. It skips paragraphs containing opaque inline content such as code, images, or HTML.

`IgnoredWords` exempts exact, case-sensitive words; in initial styles, exempt items neither establish nor match a baseline. `PreserveMixedCase: true` preserves brands and acronyms such as `macOS` and `API` without establishing a consistency baseline. Set it to `false` to check their initials normally; this does not lowercase internal capitals. `MinorWords` replaces the defaults, matches case-insensitively, and affects only title case. An empty list requires every word to be capitalized. Ignored words take precedence over other checks.

Supports unsafe autocorrection with `rubocop -A`, since casing can change proper names or identifiers. Initial-style corrections replace only the first letter. Title-case corrections require a unique, contiguous source mapping outside protected inline syntax; split formatting, links, encoded entities, and multiline text may remain report-only. Container markers, task checkboxes, nested lists, and later paragraphs are preserved.

## Configuration

```yaml
Markdown/ListItemCapitalization:
  Enabled: false
  EnforcedStyle: consistent
  PreserveMixedCase: true
  IgnoredWords: []
  MinorWords:
    - a
    - an
    - and
    - as
    - at
    - but
    - by
    - for
    - from
    - in
    - nor
    - of
    - 'on'
    - or
    - per
    - the
    - to
    - via
    - vs
    - with
```

## Consistent Initials

### Bad

```markdown
- Build the package
- run the tests.
```

### Good

```markdown
- Build the package
- Run the tests.
  - check the output
  - review the logs
```

## Initial Capitals

For this configuration:

```yaml
Markdown/ListItemCapitalization:
  Enabled: true
  EnforcedStyle: initial_capital
```

### Bad

```markdown
- build the package
- run the tests
```

### Good

```markdown
- Build the package
- Run the tests
```

## Title Case and Word Settings

For this configuration:

```yaml
Markdown/ListItemCapitalization:
  Enabled: true
  EnforcedStyle: title_case
  PreserveMixedCase: false
  IgnoredWords:
    - macOS
    - npm
  MinorWords:
    - the
    - with
```

### Bad

```markdown
- getting started with macOS
- Using The API with npm
```

### Good

```markdown
- Getting Started with macOS
- Using the API with npm
```
