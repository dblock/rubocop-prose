# Markdown/HeadingCapitalization

Checks ATX and Setext headings, ignoring emphasis delimiters, link syntax, and leading punctuation or numbers. `EnforcedStyle: title_case` (the default) checks each word, keeping internal minor words lowercase. `initial_capital` checks only the first prose letter; remaining words retain their capitalization. Neither style enforces strict sentence case.

Lowercase openings inside inline code or quoted terms are reported, including ``## `excalc` usage`` and `## "excalc" usage`; neither their literal contents nor later words are changed. Opaque leading content such as HTML or images is conservatively skipped. `PreserveMixedCase: true` (the default) preserves mixed-case words such as `eBay`, `iOS`, and `macOS` where an initial capital is required, in either style. Set it to `false` to require uppercase initials even for those words. `IgnoredWords` still takes precedence.

Use native RuboCop suppression directives for intentional lowercase headings. [Prose/ProperNames](../prose/proper_names.md) independently enforces configured canonical spellings; its configuration does not exempt headings from this cop.

`IgnoredWords` skips exact, case-sensitive whole words in either style without exempting the rest of the heading. Mixed-case brands such as `macOS` already pass; use this option for additional spellings such as `npm`.

Supports unsafe autocorrection (`rubocop -A`): capitalization may express proper-name intent, and changing a heading can change its generated link anchor. Corrections preserve prefixes, closing markers, and Setext underlines. They are offered only when the rendered heading text maps to one contiguous, unique source span outside protected inline syntax. Split formatting, links, encoded entities, multiline headings, and other ambiguous mappings remain report-only.

## Configuration

```yaml
Markdown/HeadingCapitalization:
  Enabled: false
  EnforcedStyle: title_case
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

## Initial Capital

For this configuration:

```yaml
Markdown/HeadingCapitalization:
  Enabled: true
  EnforcedStyle: initial_capital
```

### Bad

```markdown
## installing the package

*getting* started
-----------------
```

### Good

```markdown
## Installing the package

*Getting* started
-----------------

## `Excalc` usage

## eBay integration
```

## Title Case

For this configuration:

```yaml
Markdown/HeadingCapitalization:
  Enabled: true
  EnforcedStyle: title_case
```

### Bad

```markdown
## Getting started with the API

## Getting Started With The API

## the API and
```

### Good

```markdown
## Getting Started with the API

## The API And

## Getting Started with macOS and the API
```

The minor words are `a`, `an`, `and`, `as`, `at`, `but`, `by`, `for`, `from`, `in`, `nor`, `of`, `on`, `or`, `per`, `the`, `to`, `via`, `vs`, and `with`. They must be lowercase except as the first or last word. Other words must start uppercase, with mixed-case words also accepted when `PreserveMixedCase` is enabled. Acronyms with uppercase initials and uncased scripts are accepted regardless of that option. Apostrophes stay within words; hyphens separate words, as in `Don't Re-enter the API`.

This is a word-based policy, not grammatical analysis or a publishing style manual. Title case skips the entire heading when it contains inline code, HTML, images, or other opaque content rather than guessing word boundaries, except that a lowercase literal opening is reported without correction.

### Customize Minor Words

`MinorWords` replaces the default list and matches case-insensitively. It affects only `title_case`; first and last words still require capitals. Set it to `[]` to capitalize every word. `IgnoredWords` takes precedence over minor-word rules.

For this configuration:

```yaml
Markdown/HeadingCapitalization:
  Enabled: true
  EnforcedStyle: title_case
  MinorWords:
    - and
    - the
```

#### Bad

```markdown
## Getting Started with the API
```

#### Good

```markdown
## Getting Started With the API
```

## Ignore Specific Words

For example, with `PreserveMixedCase: false`, `## Using macOS` is reported in title-case style unless `macOS` is included in `IgnoredWords`.

For this configuration:

```yaml
Markdown/HeadingCapitalization:
  Enabled: true
  EnforcedStyle: title_case
  IgnoredWords:
    - macOS
    - npm
```

### Bad

```markdown
## Getting started with macOS

## Using npmlike on macOS
```

### Good

```markdown
## Getting Started with macOS

## Using npm on macOS
```

Entries are individual words, not phrases or patterns. Ignoring `npm` does not ignore `npmlike` or exempt other lowercase words.

### Suppress an Intentional Lowercase Heading

```markdown
<!-- # rubocop:disable Markdown/HeadingCapitalization -->
## npm usage
<!-- # rubocop:enable Markdown/HeadingCapitalization -->
```
