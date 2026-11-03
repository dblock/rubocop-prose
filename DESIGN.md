# Design

## Scope and naming

This plugin implements native Ruby checks for Markdown prose, structure, and style. Its public rule names are `Prose/*` cop badges, and every document cop is disabled by default. User configuration and supported behavior are documented in [the README cop catalog](README.md#cop-catalog).

The current format is Markdown, not plain text. File recognition is centralized in `Document.file?`; adding another format requires explicit parsing and cop-applicability decisions rather than treating plain text as Markdown. Ruby snippet evaluation and spelling are outside the plugin's scope.

## Plugin and source dispatch

`lib/rubocop-prose.rb` loads document support and all cop implementations. `Prose.default_configuration` merges the shared defaults and per-cop YAML files. The `lint_roller` plugin presents that configuration to RuboCop as a temporary YAML file.

`Source` extends `RuboCop::ProcessedSource`. For standalone Markdown, it initializes Ruby parsing with an empty string and retains the untouched document in a separate source buffer. It marks the source as non-Ruby syntax so ordinary Ruby AST cops do not investigate prose. `Base.on_other_file` invokes document investigation, and `Base.current_corrector` supplies a document corrector even when Ruby syntax is invalid.

Document instances are cached on the processed source by the front-matter setting, allowing enabled cops to share parsing without mixing different configurations. Hidden native RuboCop directives are surfaced as source comments only outside parsed code and ignored metadata.

## Original-source parsing and ranges

`Document` retains the original buffer and creates character-based `Parser::Source::Range` objects. It uses a Kramdown GFM parser extension to record paragraph source text, code-block source locations, and atomic inline spans such as links, code, HTML, and task-list markers. Byte offsets from parser scanners are converted into character positions before mapping back to the document, preserving Unicode locations.

Front matter is masked only in the text supplied to prose parsing, retaining line endings and character positions. The original buffer is never rewritten for filtering. Only closed leading headers are metadata; unclosed or non-initial delimiters remain Markdown. The shared setting changes Markdown inspection, not YAML validation or another processor's Ruby extraction. Hidden directives in ignored front matter remain inactive.

The parser supplies document structure, but source-aware scanners are needed for malformed constructs that do not become AST nodes, including uneven tables and missing heading separators. These scanners must exclude code, escaped syntax, and ignored metadata rather than interpreting arbitrary marker-shaped text as document structure.

## Preprocessor interoperability

An optional preprocessor may expose `processed_source.markdown_document`. Its document must provide an untouched original `buffer` and the `original_range` and `processed_range` mapping methods. `Source.prose_document` parses that original buffer instead of the extracted Ruby buffer; `Base` translates ranges at the boundary where offenses and corrections enter RuboCop.

This capability-based integration preserves the preprocessor's Ruby buffer so Ruby and prose corrections can coexist. It does not replace processed Ruby with prose or require a preprocessor for standalone use. Preprocessors without the original-buffer/mapping API are unsupported. Both loading orders, repeated execution, and stdin need integration coverage because they exercise different source and correction paths.

## Correction and diagnostic policies

Paragraph wrapping operates on soft whitespace boundaries while preserving container prefixes and atomic inline syntax. Unwrapping removes soft source breaks, not Markdown hard breaks, inline-code boundaries, or HTML break semantics. An unbreakable token can still report an offense without a useful correction. Structural line-length checks report rather than rewrite headings, tables, or code.

Structural conversions are permitted only when source mapping and resulting Markdown semantics are established. Reindenting arbitrary list continuation blocks, discarding code metadata, inventing descriptive labels, or guessing target fragments is not safe correction. Where a valid offense has an ambiguous rewrite, report it without a corrector.

Parser warnings are native syntax diagnostics, not a complete CommonMark validator. Specialized reference cops own corresponding diagnostics when enabled, preventing duplicate reporting. Fragment-anchor generation is renderer-dependent and documented as a configurable approximation; validation does not fetch external links or files.

Detailed supported syntax, scope exclusions, options, and correction limitations belong in individual cop documents so users can determine whether a rule fits their documents.

## Artwork

The logo combines the unchanged official RuboCop helmet with a vertical parchment scroll and lines of prose. Separating the two silhouettes keeps the scroll legible at the README's 160px display size. The parchment tones distinguish paper from the black helmet, while the red line echoes its visor. An opaque white background preserves contrast on dark pages.

`assets/rubocop-logo.svg` is copied unchanged from [the official website's SVG at a pinned commit](https://github.com/rubocop/rubocop.org/blob/e48d295d87264ea7dbfa0c6df7c7c4b56670979d/src/images/favicon.svg). It is derived from the original MIT-licensed vector artwork; the upstream copyright and permission notice is preserved in [assets/RUBOCOP-LICENSE](assets/RUBOCOP-LICENSE). The newly drawn scroll uses this repository's [MIT license](LICENSE.txt).

`assets/logo.svg` references that adjacent source and is rendered to a 512px PNG. Editing and rendering instructions belong in [CONTRIBUTING.md](CONTRIBUTING.md#artwork). All artwork sources, the image, and the upstream notice are packaged together.
