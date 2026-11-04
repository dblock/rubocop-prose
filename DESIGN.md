# Design

## Scope and naming

This plugin implements native Ruby checks for Markdown and plain-text prose. `Prose/*` cop badges identify shared policies, `Markdown/*` identify Markdown-specific policies, and `Text/*` identify plain-text-specific policies. Common-sense cleanup and single-line paragraphs are enabled by default; project-specific structure, editorial choices, and renderer-dependent policies remain opt-in. User configuration and supported behavior are documented in [the README cops section](README.md#cops).

File recognition is centralized in the configuration-local `FileTypes` resolver, exposed through `Document.format`, and `Document.build` dispatches to `MarkdownDocument` or `TextDocument`. `Markdown/Include` and `Text/Include` contain native file patterns; a file matching both formats is a configuration error. Matching delegates to RuboCop's configuration matcher with the original configuration path. `Markdown::Base` and `Text::Base` override applicability using the source's resolved format; shared `Prose::Base` only requires a recognized prose format. Selecting a Markdown cop cannot make it inspect text. Ruby snippet evaluation and spelling are outside the plugin's scope.

The common document interface provides untouched buffers, Unicode ranges, lines, and paragraph formatting operations. Only `MarkdownDocument` exposes a Markdown AST, code regions, metadata, or container prefixes. `TextDocument` groups nonblank lines into paragraphs without interpreting headings, fences, HTML, links, or metadata. Its indented paragraphs can report formatting offenses but are not automatically reflowed because indentation may represent preformatted content.

## Plugin and source dispatch

`lib/rubocop-prose.rb` loads document support, all three abstract cop bases, and then the concrete cop implementations. The bases are excluded from RuboCop's registry. `Prose.default_configuration` merges the shared defaults and per-cop YAML files. The `lint_roller` plugin presents that configuration to RuboCop as a temporary YAML file.

File-pattern defaults live in `config/default.yml`, not in discovery code or adapters. Each effective RuboCop configuration caches its own pattern matchers. Shared settings from individual YAML files are merged without overwriting other department keys, preserving `Markdown/Include` alongside `Markdown/IgnoreFrontMatter`. The target finder consults the configuration store per file, including nested configurations, instead of relying on process-wide file-type state or injecting static `AllCops/Include` patterns.

RuboCop normally assigns configuration after constructing a processed source. A narrow runner bridge supplies configuration at construction when a file's configured format differs from the defaults; unchanged classifications retain RuboCop's native source factory. When bypassing that factory, retain the optional preprocessor's existing configuration-store context. Explicit files, stdin, corrected sources, and the minimum-supported runner API use the same bridge. The format is resolved before parsing and retained on the processed source; programmatic callers can supply `prose_configuration:` to its constructor.

`Source` extends `RuboCop::ProcessedSource`. For standalone Markdown and all plain text, it initializes Ruby parsing with an empty string and retains the untouched document in a separate source buffer. It marks the source as non-Ruby syntax so ordinary Ruby AST cops do not investigate prose. `Base.on_other_file` invokes document investigation, and `Base.current_corrector` supplies a document corrector even when Ruby syntax is invalid.

The source installs its parsing wrapper on the instance so it runs before optional preprocessor wrappers regardless of loading order. Text never supplies its contents to Markdown preprocessing, even when its configured extension would otherwise be recognized by a preprocessor. Markdown files with no original-source mapping are parsed standalone, discarding provisional Ruby diagnostics and tokens.

Document instances are cached on the processed source by configuration identity, allowing enabled cops to share parsing without hashing mutable configuration values or mixing different configurations. Markdown document construction resolves and validates `Markdown/IgnoreFrontMatter`, including for shared prose cops; text construction never reads Markdown options. Directive scanning uses a separate default document so leading metadata remains excluded from hidden directives. Hidden native RuboCop directives are surfaced as source comments only for Markdown outside parsed code and ignored metadata; all directive-shaped text remains literal in `.txt`.

Each Markdown document lazily indexes its AST by node type and shares paragraph lines, multiline inline-atom ranges, and link scanning across cops. Reference definitions are indexed by normalized ID with the first definition winning. These caches belong to one document, not a process or cop instance, so corrected sources and different configurations cannot reuse stale analysis. Configuration-dependent link policies are still evaluated by each cop.

## Original-source parsing and ranges

`Document` retains the original buffer and creates character-based `Parser::Source::Range` objects. `MarkdownDocument` uses a Kramdown GFM parser extension to record paragraph source text, code-block source locations, and atomic inline spans such as links, code, HTML, and task-list markers. Byte offsets from parser scanners are converted into character positions before mapping back to the document, preserving Unicode locations.

Front matter is masked only in the text supplied to prose parsing, retaining line endings and character positions. The original buffer is never rewritten for filtering. Only closed leading headers are metadata; an optional BOM and CRLF line endings are supported. Unclosed or non-initial delimiters remain Markdown. The shared setting changes Markdown inspection, not YAML validation or another processor's Ruby extraction. Hidden directives in ignored front matter remain inactive.

The parser supplies document structure, but source-aware scanners are needed for malformed constructs that do not become AST nodes, including uneven tables and missing heading separators. These scanners must exclude code, escaped syntax, and ignored metadata rather than interpreting arbitrary marker-shaped text as document structure.

Inline formatting helpers protect code spans, links and their labels, escapes, and HTML. The link scanner separately retains original reference spellings and duplicate definitions that AST resolution discards, normalizes reference IDs, and excludes footnotes and raw HTML regions. Table scanning respects escaped pipes and matching backtick runs, recognizes header-plus-delimiter tables even with malformed body rows, and maps root and blockquote rows to original source positions.

Heading fragments use rendered text, including code spans, entities, and image alt text. GitHub-style slugs lowercase text, retain Unicode letters/marks/numbers and underscores, remove punctuation, and replace spaces with hyphens. GitLab additionally collapses consecutive hyphens. Kramdown uses ASCII letters/numbers/spaces/hyphens, discards nonletter prefixes, and falls back to `section`. Duplicate slugs receive collision-aware numeric suffixes. These algorithms approximate renderer behavior rather than guaranteeing every renderer version or extension.

## Preprocessor interoperability

An optional preprocessor may expose `processed_source.markdown_document`. Its document must provide an untouched original `buffer` and the `original_range` and `processed_range` mapping methods. `Source.prose_document` parses that original buffer instead of the extracted Ruby buffer; `Base` translates ranges at the boundary where offenses and corrections enter RuboCop.

This capability-based integration preserves the preprocessor's Ruby buffer so Ruby and prose corrections can coexist. It does not replace processed Ruby with prose or require a preprocessor for standalone use. Plain text never consults this API, even when a preprocessor is loaded. Preprocessors without the original-buffer/mapping API are unsupported. Both loading orders, repeated execution, and stdin need integration coverage because they exercise different source and correction paths.

Custom Markdown extensions do not reconfigure another processor's file recognition. When the preprocessor does not recognize an extension, prose rules still run standalone and fenced Ruby is not extracted.

The `Markdown:` settings section is shared with optional preprocessors. `IgnoreFrontMatter` belongs to this plugin; other keys are preserved and remain owned by their processor. Native department enable/disable settings do not control preprocessing itself. Interoperability fixtures cover that separation and preprocessing settings with the department disabled.

## Correction and diagnostic policies

Paragraph wrapping operates on soft whitespace boundaries supplied by each adapter. Markdown preserves container prefixes and atomic inline syntax; its unwrapping retains Markdown hard breaks, inline-code boundaries, and HTML break semantics. Text treats these characters literally and preserves blank paragraph boundaries. An unbreakable token can still report an offense without a useful correction. `Markdown/StructuralLineLength` independently reports rather than rewrites heading, table, or code source.

`Prose/MultipleBlankLines` also counts quote-only blank source lines only when parsed as blank nodes within a blockquote, keeping runs separate by parsed container and excluding quoted code. It removes only excess complete lines, so retained quote markers and paragraph separation remain intact; literal text is never interpreted as Markdown.

Structural conversions are permitted only when source mapping and resulting Markdown semantics are established. Reindenting arbitrary list continuation blocks, discarding code metadata, inventing descriptive labels, or guessing target fragments is not safe correction. Where a valid offense has an ambiguous rewrite, report it without a corrector.

General blank-line cleanup derives Markdown boundary minimums from the effective configuration of enabled, file-applicable heading, fence, list, and table spacing cops, using their shared structural selectors. It protects only the blank lines needed for those minimums; shared boundaries retain the largest requirement, with marker-only blank lines contributing to the protected minimum. Excess marker-only lines remain eligible for container-aware cleanup. Heading and fence document/front-matter exemptions and fence list-item exclusions remain intact. Plain text never consults structural settings, and ordinary paragraph gaps retain the general limit.

Fence-style corrections replace both delimiters and choose a length greater than any conflicting content delimiter run. Code-block style conversions require reproducible source mappings and standalone root blocks with blank boundaries; indentation-to-fence conversion requires literal four-space indentation, and conversion to indentation rejects adjacent code blocks to avoid merging them. Table corrections change exterior pipes or cell-edge padding without changing contents. Alignment measures source characters, not terminal display width.

`Markdown/ThematicBreakStyle` accepts a single literal or a positive list of literal thematic breaks. In consistent mode the first parsed thematic break remains the correction target; a single configured spelling is also safe to correct to. A disallowed spelling under a multi-value list is report-only because choosing one accepted separator could change its intended meaning.

Parser warnings are native syntax diagnostics, not a complete CommonMark validator. Specialized reference cops own corresponding diagnostics when enabled, preventing duplicate reporting. Fragment-anchor generation is renderer-dependent and documented as a configurable approximation; validation does not fetch external links or files.

Cop guides document user-visible behavior and meaningful correction limits. Shared inspection behavior belongs in the README; parsing, source mapping, and correction algorithms belong here.

## Artwork

The logo combines the unchanged official RuboCop helmet with a vertical parchment scroll and lines of prose. Separating the two silhouettes keeps the scroll legible at the README's 160px display size. The parchment tones distinguish paper from the black helmet, while the red line echoes its visor. An opaque white background preserves contrast on dark pages.

`assets/rubocop-logo.svg` is copied unchanged from [the official website's SVG at a pinned commit](https://github.com/rubocop/rubocop.org/blob/e48d295d87264ea7dbfa0c6df7c7c4b56670979d/src/images/favicon.svg). It is derived from the original MIT-licensed vector artwork; the upstream copyright and permission notice is preserved in [assets/RUBOCOP-LICENSE](assets/RUBOCOP-LICENSE). The newly drawn scroll uses this repository's [MIT license](LICENSE.txt).

`assets/logo.svg` references that adjacent source and is rendered to a 512px PNG. Editing and rendering instructions belong in [CONTRIBUTING.md](CONTRIBUTING.md#artwork). All artwork sources, the image, and the upstream notice are packaged together.
