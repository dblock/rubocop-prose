# Prose/DuplicateHeadings

Related rule: MD024. Disabled by default.

`Scope: document` (default) reports repeated heading text anywhere. `Scope: siblings` compares headings under the same nearest preceding lower-level heading; root headings share a scope, and a new parent heading starts a new scope even if its text repeats.

Comparison is case-sensitive parsed plain text, including inline-code text but ignoring emphasis markers; no slug generation, case folding or whitespace normalization is performed. This is intentionally not a promise of markdownlint-identical text normalization. ATX and Setext headings participate; code and front matter do not.

Report-only: renaming headings can break links and alter meaning.
