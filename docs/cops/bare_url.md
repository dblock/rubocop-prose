# Prose/BareUrl

Inspired by markdownlint MD034; disabled by default.

Reports literal `http://`, `https://`, and `ftp://` URLs in prose. `Schemes` configures this list; an empty list disables URL matching. Trailing sentence punctuation and unmatched closing brackets are excluded from the offense range.

```markdown
Read https://example.test/docs.
```

Use `<https://example.test/docs>` or `[the documentation](https://example.test/docs)` instead. The rule is report-only: automatically choosing autolinks over descriptive text is an editorial decision.

Markdown links and images (including resolved references), definitions, angle autolinks, code spans/blocks, front matter, HTML tags/comments and raw HTML blocks/regions are excluded. Plain email addresses, `www.` without a scheme, and URLs assembled with Markdown escapes are intentionally not detected; this is not a claim of exact markdownlint URL recognition.
