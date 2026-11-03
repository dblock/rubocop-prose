# Cop catalog

All document cops are opt-in. Add `plugins: [rubocop-prose]` to `.rubocop.yml`, then enable the individual `Prose/*` cops you want. Each linked document describes configuration, autocorrection safety, and intentional differences from markdownlint; these are native Ruby implementations rather than a wrapper or a promise of exact markdownlint parity.

This catalog covers all 53 current rule IDs discussed in [rubocop-md#54](https://github.com/rubocop/rubocop-md/issues/54), plus paragraph unwrapping, parser diagnostics, and configurable front-matter exclusion from the related prose proposals.

| Rule | Cop |
| ---- | --- |
| MD001 | [Prose/HeadingIncrement](cops/heading_increment.md) |
| MD003 | [Prose/HeadingStyle](cops/heading_style.md) |
| MD004 | [Prose/UnorderedListMarker](cops/unordered_list_marker.md) |
| MD005 | [Prose/ListIndentation](cops/list_indentation.md) |
| MD007 | [Prose/UnorderedListIndentation](cops/unordered_list_indentation.md) |
| MD009 | [Prose/TrailingWhitespace](cops/trailing_whitespace.md) |
| MD010 | [Prose/HardTabs](cops/hard_tabs.md) |
| MD011 | [Prose/ReversedLink](cops/reversed_link.md) |
| MD012 | [Prose/MultipleBlankLines](cops/multiple_blank_lines.md) |
| MD013 | [Prose/MaxLength](cops/max_length.md) |
| MD014 | [Prose/ShellPrompts](cops/shell_prompts.md) |
| MD018 | [Prose/AtxHeadingSpace](cops/atx_heading_space.md) |
| MD019 | [Prose/AtxHeadingSpacing](cops/atx_heading_spacing.md) |
| MD020 | [Prose/ClosedHeadingSpace](cops/closed_heading_space.md) |
| MD021 | [Prose/ClosedHeadingSpacing](cops/closed_heading_spacing.md) |
| MD022 | [Prose/HeadingBlankLines](cops/heading_blank_lines.md) |
| MD023 | [Prose/HeadingIndentation](cops/heading_indentation.md) |
| MD024 | [Prose/DuplicateHeadings](cops/duplicate_headings.md) |
| MD025 | [Prose/SingleTopLevelHeading](cops/single_top_level_heading.md) |
| MD026 | [Prose/HeadingPunctuation](cops/heading_punctuation.md) |
| MD027 | [Prose/BlockquoteSpacing](cops/blockquote_spacing.md) |
| MD028 | [Prose/BlockquoteBlankLines](cops/blockquote_blank_lines.md) |
| MD029 | [Prose/OrderedListNumbering](cops/ordered_list_numbering.md) |
| MD030 | [Prose/ListMarkerSpacing](cops/list_marker_spacing.md) |
| MD031 | [Prose/FenceBlankLines](cops/fence_blank_lines.md) |
| MD032 | [Prose/ListBlankLines](cops/list_blank_lines.md) |
| MD033 | [Prose/RawHtml](cops/raw_html.md) |
| MD034 | [Prose/BareUrl](cops/bare_url.md) |
| MD035 | [Prose/ThematicBreakStyle](cops/thematic_break_style.md) |
| MD036 | [Prose/EmphasisHeading](cops/emphasis_heading.md) |
| MD037 | [Prose/EmphasisSpacing](cops/emphasis_spacing.md) |
| MD038 | [Prose/CodeSpanSpacing](cops/code_span_spacing.md) |
| MD039 | [Prose/LinkTextSpacing](cops/link_text_spacing.md) |
| MD040 | [Prose/FenceLanguage](cops/fence_language.md) |
| MD041 | [Prose/FirstHeading](cops/first_heading.md) |
| MD042 | [Prose/EmptyLink](cops/empty_link.md) |
| MD043 | [Prose/HeadingStructure](cops/heading_structure.md) |
| MD044 | [Prose/ProperNames](cops/proper_names.md) |
| MD045 | [Prose/ImageAltText](cops/image_alt_text.md) |
| MD046 | [Prose/CodeBlockStyle](cops/code_block_style.md) |
| MD047 | [Prose/TrailingNewline](cops/trailing_newline.md) |
| MD048 | [Prose/FenceStyle](cops/fence_style.md) |
| MD049 | [Prose/EmphasisStyle](cops/emphasis_style.md) |
| MD050 | [Prose/StrongStyle](cops/strong_style.md) |
| MD051 | [Prose/LinkFragment](cops/link_fragment.md) |
| MD052 | [Prose/UndefinedReference](cops/undefined_reference.md) |
| MD053 | [Prose/ReferenceDefinitions](cops/reference_definitions.md) |
| MD054 | [Prose/LinkStyle](cops/link_style.md) |
| MD055 | [Prose/TablePipes](cops/table_pipes.md) |
| MD056 | [Prose/TableColumns](cops/table_columns.md) |
| MD058 | [Prose/TableBlankLines](cops/table_blank_lines.md) |
| MD059 | [Prose/DescriptiveLinkText](cops/descriptive_link_text.md) |
| MD060 | [Prose/TableSpacing](cops/table_spacing.md) |

`Prose/MaxLength` also supports [paragraph unwrapping](cops/max_length.md) with `Max: false`. [Prose/Syntax](cops/syntax.md) exposes parser diagnostics without duplicating enabled reference cops. The shared [front-matter setting](cops/front_matter.md) controls whether prose cops inspect leading document metadata; it is not a YAML linter or a setting for Ruby extraction.

Markdown rendering varies between implementations. Link-fragment algorithms are documented approximations, unsafe structural rewrites are withheld, and no links or external files are fetched.
