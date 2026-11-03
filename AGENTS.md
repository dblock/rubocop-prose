# Contributor instructions

Read [CONTRIBUTING.md](CONTRIBUTING.md) for setup, validation, and pull-request conventions, and [DESIGN.md](DESIGN.md) before changing document parsing, source mapping, or correction behavior.

Keep changes focused and preserve existing configuration and supported Ruby/RuboCop versions. All document cops are opt-in. Do not add a dependency on an external preprocessor for standalone linting.

Preserve untouched original source buffers, character-based locations, Markdown container prefixes, hard breaks, and atomic inline syntax. Withhold corrections when the intended rewrite cannot be established safely. Add focused regression coverage for behavior changes, including original-source ranges and repeated correction where relevant.

Use `Prose/*` for shared rules, `Markdown/*` for Markdown-only policies, and `Text/*` for text-only policies. New cops need per-cop configuration, tests, a user-facing document with good/bad examples, and a one-line entry in the README catalog. Avoid numeric aliases from other rule catalogs and comparisons with other plugins; retain functional dependency loading and compatibility CI settings.

Do not parse Markdown syntax or interpret hidden HTML directives in plain text. Enforce format applicability before a cop accesses format-specific document APIs. Keep integration specs and fixtures grouped by prose, Markdown, text, and Markdown interoperability.

Resolve configurable file patterns from each file's effective configuration before source parsing. Reuse the shared resolver for discovery and applicability; do not introduce independent file-type lists or a global format registry.

Keep user instructions in README and per-cop documentation, developer instructions in CONTRIBUTING, and architecture/rationale in DESIGN. Do not hard-wrap Markdown paragraphs. Include a linked pull-request changelog entry.

Do not modify the vendored upstream helmet SVG or remove its license. Regenerate the PNG after editing the logo composition and check both full-size and README-size rendering.
