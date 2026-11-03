# Prose/ReversedLink

Inspired by markdownlint MD011; disabled by default.

Reports adjacent `(link text)[destination]` with a nonblank label and a whitespace-free bracketed destination. Nested parentheses and escaped delimiters are respected. This is deliberately a source-level typo heuristic, not perfect markdownlint equivalence: whitespace-separated parentheses followed by a reference, and references that actually resolve, are not treated as reversed links.

```markdown
(Documentation)[https://example.test]
```

Use `[Documentation](https://example.test)` instead. The rule is report-only because rewriting arbitrary reversed syntax can change its intended meaning.

Code blocks, code spans, front matter, HTML tags/comments/raw regions, autolinks, valid links, and escaped delimiters are excluded by the shared source scanner.
