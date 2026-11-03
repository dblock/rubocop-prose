# Prose/MaxLength

Opt-in paragraph formatting, extracted from rubocop-md#50. `Max` is a positive character count (default `80`), including source container prefixes, or `false` to keep each paragraph on one source line. Autocorrection wraps at whitespace, preserves list/blockquote prefixes, and does not split links, inline code, HTML atoms, escapes, or task-list markers. Code blocks, front matter, tables, and headings are not reformatted by this paragraph rule.

Unbreakable tokens can remain over the limit and report without a usable correction. This is intentionally a paragraph formatter, not a byte-for-byte implementation of markdownlint MD013.

With `Max: false`, soft source line breaks are joined with one space. Blank lines still separate paragraphs, and Markdown hard breaks, `<br>` boundaries, multiline inline code, and HTML-only blocks retain their semantics.
