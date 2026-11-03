# rubocop-prose

<img src="assets/logo.png" alt="The RuboCop helmet logo with a parchment scroll alongside it." width="160">

Markdown prose, structure, and style checks for RuboCop. Check headings, lists, links, tables, whitespace, and paragraph formatting using native `Prose/*` cops.

## Installation

The initial release is in development. Add this repository to your Gemfile:

```ruby
gem 'rubocop-prose', github: 'dblock/rubocop-prose'
```

Load it using RuboCop's plugin interface:

```yaml
plugins:
  - rubocop-prose
```

Ruby 3.2 or newer and RuboCop 1.72.1 or newer within 1.x are supported. No JavaScript runtime or external linter is needed.

## Usage

All cops are opt-in. For example, enable paragraph unwrapping in `.rubocop.yml`:

```yaml
Prose/MaxLength:
  Enabled: true
  Max: false
```

Given `example.md`:

```markdown
A paragraph split
across two source lines.
```

Run:

```sh
bundle exec rubocop example.md
```

```text
example.md:2:1: C: [Correctable] Prose/MaxLength: Keep paragraph text on a single source line.
across two source lines.
^^^^^^^^^^^^^^^^^^^^^^^^
```

Fix it automatically with `bundle exec rubocop -a example.md`.

## Configuration

With `Max: false`, paragraph formatting keeps each paragraph on one source line; set a positive character count to wrap paragraphs instead. The [cop catalog](#cop-catalog) lists all available cops, options, and supported scope.

Supported extensions are `.md`, `.markdown`, `.mdown`, `.mdwn`, `.mkd`, `.mkdn`, `.mkdown`, `.livemd`, `.ronn`, `.scd`, and `.workbook`, matched case-insensitively. Ruby files are unaffected; plain-text `.txt` files are not currently supported.

Leading [front matter](docs/cops/front_matter.md) is ignored by default. Hidden directives use native RuboCop syntax, for example `<!-- # rubocop:disable Prose/MaxLength -->`; directives inside code or metadata do not control prose cops.

Standalone Markdown linting requires no additional preprocessor. Optional preprocessing integrations must expose the original Markdown buffer and source-range mapping described in [DESIGN.md](DESIGN.md#preprocessor-interoperability).

## Cop catalog

All cops are opt-in. Follow each link for configuration, supported scope, and good/bad examples.

| Cop | Purpose |
| --- | ------- |
| [Prose/AtxHeadingSpace](docs/cops/atx_heading_space.md) | Separate opening ATX heading hashes from text. |
| [Prose/AtxHeadingSpacing](docs/cops/atx_heading_spacing.md) | Use one space after opening ATX heading hashes. |
| [Prose/BareUrl](docs/cops/bare_url.md) | Require Markdown links or autolinks around bare URLs. |
| [Prose/BlockquoteBlankLines](docs/cops/blockquote_blank_lines.md) | Keep quote markers on blank lines between blockquotes. |
| [Prose/BlockquoteSpacing](docs/cops/blockquote_spacing.md) | Avoid multiple spaces after blockquote markers. |
| [Prose/ClosedHeadingSpace](docs/cops/closed_heading_space.md) | Separate closing ATX heading hashes from text. |
| [Prose/ClosedHeadingSpacing](docs/cops/closed_heading_spacing.md) | Use one space before closing ATX heading hashes. |
| [Prose/CodeBlockStyle](docs/cops/code_block_style.md) | Use fenced, indented, or consistently styled code blocks. |
| [Prose/CodeSpanSpacing](docs/cops/code_span_spacing.md) | Avoid unnecessary padding inside inline code. |
| [Prose/DescriptiveLinkText](docs/cops/descriptive_link_text.md) | Require descriptive link text instead of generic labels. |
| [Prose/DuplicateHeadings](docs/cops/duplicate_headings.md) | Avoid duplicate heading text. |
| [Prose/EmphasisHeading](docs/cops/emphasis_heading.md) | Avoid single-line emphasis-only paragraphs in place of headings. |
| [Prose/EmphasisSpacing](docs/cops/emphasis_spacing.md) | Remove whitespace immediately inside emphasis delimiters. |
| [Prose/EmphasisStyle](docs/cops/emphasis_style.md) | Use a configured or consistent emphasis delimiter. |
| [Prose/EmptyLink](docs/cops/empty_link.md) | Require a nonempty link destination. |
| [Prose/FenceBlankLines](docs/cops/fence_blank_lines.md) | Surround fenced code blocks with container-aware blank lines. |
| [Prose/FenceLanguage](docs/cops/fence_language.md) | Require a language and optionally restrict fence languages. |
| [Prose/FenceStyle](docs/cops/fence_style.md) | Use backtick, tilde, or consistently styled fences. |
| [Prose/FirstHeading](docs/cops/first_heading.md) | Begin documents with a heading or front-matter title. |
| [Prose/HardTabs](docs/cops/hard_tabs.md) | Disallow hard tabs with code-language exceptions. |
| [Prose/HeadingBlankLines](docs/cops/heading_blank_lines.md) | Surround headings with blank lines. |
| [Prose/HeadingIncrement](docs/cops/heading_increment.md) | Increase heading levels without skipping levels. |
| [Prose/HeadingIndentation](docs/cops/heading_indentation.md) | Avoid leading indentation before headings. |
| [Prose/HeadingPunctuation](docs/cops/heading_punctuation.md) | Avoid configured trailing heading punctuation. |
| [Prose/HeadingStructure](docs/cops/heading_structure.md) | Match a configured exact heading outline. |
| [Prose/HeadingStyle](docs/cops/heading_style.md) | Use a consistent heading syntax. |
| [Prose/ImageAltText](docs/cops/image_alt_text.md) | Require nonblank Markdown image alternative text. |
| [Prose/LinkFragment](docs/cops/link_fragment.md) | Validate local fragments using configurable heading anchors. |
| [Prose/LinkStyle](docs/cops/link_style.md) | Configure permitted link and image styles independently. |
| [Prose/LinkTextSpacing](docs/cops/link_text_spacing.md) | Remove leading and trailing whitespace from link text. |
| [Prose/ListBlankLines](docs/cops/list_blank_lines.md) | Surround parsed lists with blank lines. |
| [Prose/ListIndentation](docs/cops/list_indentation.md) | Keep sibling list markers consistently indented. |
| [Prose/ListMarkerSpacing](docs/cops/list_marker_spacing.md) | Configure spaces after ordered and unordered list markers. |
| [Prose/MaxLength](docs/cops/max_length.md) | Wrap long prose lines without splitting Markdown tokens. |
| [Prose/MultipleBlankLines](docs/cops/multiple_blank_lines.md) | Limit consecutive blank lines outside code. |
| [Prose/OrderedListNumbering](docs/cops/ordered_list_numbering.md) | Use sequential numbers or repeated ones in ordered lists. |
| [Prose/ProperNames](docs/cops/proper_names.md) | Use configured capitalization for proper names. |
| [Prose/RawHtml](docs/cops/raw_html.md) | Disallow raw HTML except explicitly allowed elements. |
| [Prose/ReferenceDefinitions](docs/cops/reference_definitions.md) | Report unused and duplicate reference definitions. |
| [Prose/ReversedLink](docs/cops/reversed_link.md) | Report reversed Markdown link delimiters. |
| [Prose/ShellPrompts](docs/cops/shell_prompts.md) | Omit dollar prompts in shell-only examples without output. |
| [Prose/SingleTopLevelHeading](docs/cops/single_top_level_heading.md) | Allow at most one top-level heading. |
| [Prose/StrongStyle](docs/cops/strong_style.md) | Use a configured or consistent strong delimiter. |
| [Prose/Syntax](docs/cops/syntax.md) | Report native Markdown parser diagnostics. |
| [Prose/TableBlankLines](docs/cops/table_blank_lines.md) | Surround Markdown tables with blank lines. |
| [Prose/TableColumns](docs/cops/table_columns.md) | Match table body column counts to the header. |
| [Prose/TablePipes](docs/cops/table_pipes.md) | Use consistent leading and trailing table pipes. |
| [Prose/TableSpacing](docs/cops/table_spacing.md) | Use configured spacing around table cell content. |
| [Prose/ThematicBreakStyle](docs/cops/thematic_break_style.md) | Use a configured or consistent thematic break. |
| [Prose/TrailingNewline](docs/cops/trailing_newline.md) | Require exactly one final newline. |
| [Prose/TrailingWhitespace](docs/cops/trailing_whitespace.md) | Remove trailing whitespace while retaining Markdown hard breaks. |
| [Prose/UndefinedReference](docs/cops/undefined_reference.md) | Require definitions for link and image references. |
| [Prose/UnorderedListIndentation](docs/cops/unordered_list_indentation.md) | Use a configured indentation width for unordered lists. |
| [Prose/UnorderedListMarker](docs/cops/unordered_list_marker.md) | Use a configured or consistent unordered list marker. |

The shared [front-matter setting](docs/cops/front_matter.md) controls inspection of leading metadata; it is not a cop or a YAML linter.

## Project documentation

[CONTRIBUTING.md](CONTRIBUTING.md) covers development, testing, and artwork maintenance. [DESIGN.md](DESIGN.md) explains architecture and design decisions. [AGENTS.md](AGENTS.md) provides contributor instructions for coding agents.

## License

Released under the [MIT license](LICENSE.txt).
