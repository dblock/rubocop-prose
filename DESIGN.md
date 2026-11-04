# Design

## Scope and file selection

The plugin checks Markdown and plain-text prose without evaluating Ruby snippets. `Prose/*` policies apply to both formats; `Markdown/*` and `Text/*` are format-specific. Common cleanup is enabled by default, while project-specific, editorial, and renderer-dependent policies remain opt-in. User-visible behavior and defaults are in [the README cops catalog](README.md#cops) and the cop guides.

`Markdown/Include` and `Text/Include` are resolved by `FileTypes` from each file's effective RuboCop configuration. The same resolver drives discovery and applicability; overlapping patterns are an error. Format selection is configuration-local, not a process-wide registry or a separate set of hard-coded extension lists.

The plugin loads document support and abstract cop bases before concrete cops, then merges shared and per-cop defaults. The runner supplies a file's configuration before source construction when its selected format differs from RuboCop's default classification. This keeps nested configuration, explicit files, stdin, and autocorrection on the same dispatch path.

## Documents and source preservation

`Document` retains the untouched input buffer and exposes character-based ranges. `MarkdownDocument` parses Markdown and provides its structure; `TextDocument` groups nonblank lines into paragraphs without interpreting headings, links, fences, HTML, or metadata. Text indentation may indicate preformatted content, so indented paragraphs can be reported but are not automatically reflowed.

Markdown parsing combines an AST with source-aware scanners for constructs that may be malformed or omitted from the tree. Scanners must exclude code, escaped syntax, and ignored metadata. Parser byte offsets are converted to character positions before they are mapped to the original source, preserving Unicode locations.

Front matter is recognized only as a closed leading header. When ignored, it is masked only in the parser input, preserving line endings and source positions; the original buffer is not rewritten. `Markdown/IgnoreFrontMatter` is resolved while constructing each Markdown document, including documents shared by `Prose/*` cops. Hidden RuboCop directives are recognized only in Markdown outside code and ignored metadata; directive-shaped text remains literal in plain text.

Standalone Markdown and all plain text initialize Ruby parsing with empty input and keep the original document in a separate buffer, preventing Ruby cops from interpreting prose. The cop bases enforce format applicability before accessing format-specific APIs. Documents are cached on the processed source by configuration identity, so cops can share analysis without mixing configuration-dependent results.

Each Markdown document shares positioned emphasis and strong ranges across style and spacing cops, including table-row source mapping. Both types are collected in one parse; style policies remain cop-local, and corrected sources receive fresh documents.

## Preprocessor interoperability

An optional Markdown preprocessor can expose `processed_source.markdown_document` with an untouched `buffer` and `original_range` / `processed_range` mapping methods. The plugin analyzes that original buffer and translates offense and correction ranges at the RuboCop boundary, preserving the preprocessor's Ruby buffer so both kinds of corrections can coexist. This API is optional; standalone Markdown and text linting do not require a preprocessor.

Plain text never consults the preprocessor API. A preprocessor without the original-buffer mapping methods is unsupported. Custom Markdown extensions remain lintable standalone when the preprocessor does not recognize them; Ruby extraction is then unavailable. The shared `Markdown:` section preserves keys owned by the preprocessor, while `IgnoreFrontMatter` belongs to this plugin.

## Correction safety

Corrections are limited to rewrites whose source mapping and resulting document semantics are known. Markdown reflow preserves container prefixes, hard breaks, inline atomic syntax, and HTML break behavior; text preserves literal contents and paragraph boundaries. Unbreakable tokens and ambiguous structural rewrites can be reported without correction. Markdown structural checks do not reflow headings, tables, or code.

Source scanners retain original reference spellings and ranges when AST resolution discards them, and protect inline constructs such as links, code, escapes, and HTML from unrelated formatting corrections. Renderer-dependent heading fragments are configurable approximations, not guarantees for every renderer or extension. Parser warnings are native syntax diagnostics rather than a complete CommonMark validation.

Bare link destinations use character-based searches to skip ordinary path text, retaining whitespace, nesting, and escape checks at candidate boundaries without changing original Unicode offsets.

Shared blank-line cleanup respects the minimum padding required by enabled, applicable Markdown structure-spacing cops, without applying those rules to plain text. When an offense has multiple plausible rewrites, the cop reports it without choosing one.

`Markdown/HardBreakStyle` applies to parser-recognized paragraph hard breaks, not arbitrary terminal backslashes or code. Its default backslash style is coordinated with `Markdown/TrailingWhitespace` so the two cops do not issue overlapping edits; conversions that could change backslash escaping are report-only.

Shell-prompt removal preserves code-content ranges and container prefixes. Blocks with output or ambiguous `#` prompts remain uncorrected; so does an entire block if removing any prompt could expose its closing delimiter. See [Markdown/ShellPrompts](docs/cops/markdown/shell_prompts.md) for prompt and language settings.

`Markdown/ListContinuationIndentation` uses parsed list-item membership and each paragraph's original-source mapping to find continuation lines, excluding following root paragraphs and child list blocks. Its expected column comes from the parsed item's marker, so ordered marker widths and container prefixes are retained. It reports only: reindentation could change Markdown block ownership, so no correction is offered.

`Markdown/ListItemPunctuation` uses parsed sibling membership and rendered inline text to check only terminal punctuation presence, not the punctuation character. Consistent mode uses the first item as its baseline; explicit always/never styles inspect every eligible item against the configured policy. It checks a list only when every item has exactly one paragraph and a source-mapped marker; code and multi-block items are ambiguous and skipped. Nested lists remain independent.

Cop guides describe user-visible behavior and correction limits. Parsing, source mapping, and correction rationale belong here rather than in individual guides.

## Artwork

The logo pairs the RuboCop helmet with a parchment scroll, keeping both silhouettes legible at the README's 160px display size. Its opaque white background preserves contrast on dark pages.

`assets/rubocop-logo.svg` is copied unchanged from [the official website's SVG at a pinned commit](https://github.com/rubocop/rubocop.org/blob/e48d295d87264ea7dbfa0c6df7c7c4b56670979d/src/images/favicon.svg). The upstream MIT copyright and permission notice is preserved in [assets/RUBOCOP-LICENSE](assets/RUBOCOP-LICENSE); the newly drawn scroll uses this repository's [MIT license](LICENSE.txt). Editing and rendering instructions are in [CONTRIBUTING.md](CONTRIBUTING.md#artwork), and all artwork sources, rendered images, and the notice are packaged together.
