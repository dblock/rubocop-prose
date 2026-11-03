# Prose/MaxLength

Opt-in paragraph wrapping, extracted from rubocop-md#50. `Max` is a positive character count (default `80`), including source container prefixes. Autocorrection wraps at whitespace, preserves list/blockquote prefixes, and does not split links, inline code, HTML atoms, escapes, or task-list markers. Code blocks, front matter, tables, and headings are not reformatted by this paragraph rule.

Unbreakable tokens can remain over the limit and report without a usable correction. This is intentionally a paragraph formatter, not a byte-for-byte implementation of markdownlint MD013.
