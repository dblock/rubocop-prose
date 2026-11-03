# Changelog

## Unreleased

- Initial RuboCop plugin foundation, with parser-backed Markdown source ranges and opt-in document cops.
- Add paragraph wrapping and unwrapping, parser diagnostics, and configurable front-matter exclusion.
- Cover 53 Markdown rule IDs across headings, lists, code blocks, links, references, whitespace, inline formatting, and tables; see the [cop catalog](docs/cops.md) for documented scope and differences.
- Verify interoperability with rubocop-md's proposed original-buffer API in both load orders, including Unicode, combined corrections, repeated runs, and stdin.
