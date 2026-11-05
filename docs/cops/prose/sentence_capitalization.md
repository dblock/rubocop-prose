# Prose/SentenceCapitalization

Checks lowercase words at paragraph openings in Markdown and plain-text files using the single `initial_capital` style. It is an opt-in editorial rule. It checks ordinary prose and reports lowercase openings inside inline code or quoted terms in Markdown, but never changes quoted or code contents. For literal terms, rewrite the sentence around the term rather than changing the literal spelling.

The cop checks paragraph openings only; it does not split paragraphs into sentences. In Markdown, it handles paragraphs in blockquotes, footnotes, and list items, but leaves each list item's opening paragraph to [Markdown/ListItemCapitalization](../markdown/list_item_capitalization.md) so consistent lowercase lists remain possible. Subsequent paragraphs in list items are checked.

In plain-text files, paragraphs are literal groups of nonblank lines. The cop does not interpret Markdown-like code, emphasis, links, or containers in text files. A quoted paragraph opening is still reported without correction. Plain-text list-item capitalization is not inferred.

Headings, tables, code blocks, and ignored front matter are not Markdown paragraphs for this rule. Mixed-case brands such as `eBay` pass by default. `IgnoredWords` exempts exact, case-sensitive words. Native RuboCop suppression directives can silence intentional Markdown exceptions; plain-text files use `IgnoredWords`.

Supports unsafe autocorrection with `rubocop -A` for a mapped ordinary prose opening only. A lowercase opening in code, quotation marks, or ambiguous source mapping is report-only. Abbreviations, URLs, decimals, and later sentence boundaries are not analyzed.

## Configuration

```yaml
Prose/SentenceCapitalization:
  Enabled: false
  SafeAutoCorrect: false
  EnforcedStyle: initial_capital
  PreserveMixedCase: true
  IgnoredWords: []
  SupportedStyles:
    - initial_capital
```

## Examples

### Bad

```markdown
lowercase prose starts this paragraph.

`fixed` requires exactly one space after every marker.

"aligned" adds padding after shorter markers.
```

### Good

```markdown
Lowercase prose starts this paragraph.

The `fixed` style requires exactly one space after every marker.

The "aligned" style adds padding after shorter markers.
```
