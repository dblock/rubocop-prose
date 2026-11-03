<img src="assets/logo.png" alt="The RuboCop helmet logo with a parchment scroll alongside it." width="160">

# rubocop-prose

[![Lint](https://github.com/dblock/rubocop-prose/actions/workflows/lint.yml/badge.svg?branch=main)](https://github.com/dblock/rubocop-prose/actions/workflows/lint.yml)
[![Tests](https://github.com/dblock/rubocop-prose/actions/workflows/test.yml/badge.svg?branch=main)](https://github.com/dblock/rubocop-prose/actions/workflows/test.yml)

Markdown and plain-text prose checks for RuboCop. Use `Prose/*` for shared formatting, `Markdown/*` for Markdown structure and style, and `Text/*` for plain-text policies.

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

With `Max: false`, paragraph formatting keeps each paragraph on one source line; set a positive character count to wrap paragraphs instead. The [cops](#cops) below list all available checks, options, and supported scope.

File selection and front-matter handling are configured through the settings under [Markdown](#markdown) and [Text](#text) below. Configured files are discovered automatically, respecting exclusions and per-directory configuration. Ruby files remain unaffected unless explicitly assigned to a prose format.

Text is literal: headings, fences, links, HTML, and front-matter-looking delimiters are ordinary content. Paragraphs are separated by blank lines. Indented text blocks can report formatting offenses but are not automatically reflowed. Enable strict plain-text whitespace independently:

```yaml
Text/TrailingWhitespace:
  Enabled: true
```

Hidden directives use native RuboCop syntax, for example `<!-- # rubocop:disable Prose/MaxLength -->`; directives inside code or ignored metadata do not control prose cops.

## Cops

All cops are opt-in. Follow each link for configuration, supported scope, and good/bad examples. Shared `Prose/*` cops appear in both tables.

### Markdown

| Cop | Purpose |
| --- | ------- |
| [Markdown/AtxHeadingSpace](docs/cops/markdown/atx_heading_space.md) | Separate opening ATX heading hashes from text. |
| [Markdown/AtxHeadingSpacing](docs/cops/markdown/atx_heading_spacing.md) | Use one space after opening ATX heading hashes. |
| [Markdown/BareUrl](docs/cops/markdown/bare_url.md) | Require Markdown links or autolinks around bare URLs. |
| [Markdown/BlockquoteBlankLines](docs/cops/markdown/blockquote_blank_lines.md) | Keep quote markers on blank lines between blockquotes. |
| [Markdown/BlockquoteSpacing](docs/cops/markdown/blockquote_spacing.md) | Avoid multiple spaces after blockquote markers. |
| [Markdown/ClosedHeadingSpace](docs/cops/markdown/closed_heading_space.md) | Separate closing ATX heading hashes from text. |
| [Markdown/ClosedHeadingSpacing](docs/cops/markdown/closed_heading_spacing.md) | Use one space before closing ATX heading hashes. |
| [Markdown/CodeBlockStyle](docs/cops/markdown/code_block_style.md) | Use fenced, indented, or consistently styled code blocks. |
| [Markdown/CodeSpanSpacing](docs/cops/markdown/code_span_spacing.md) | Avoid unnecessary padding inside inline code. |
| [Markdown/DescriptiveLinkText](docs/cops/markdown/descriptive_link_text.md) | Require descriptive link text instead of generic labels. |
| [Markdown/DuplicateHeadings](docs/cops/markdown/duplicate_headings.md) | Avoid duplicate heading text. |
| [Markdown/EmphasisHeading](docs/cops/markdown/emphasis_heading.md) | Avoid single-line emphasis-only paragraphs in place of headings. |
| [Markdown/EmphasisSpacing](docs/cops/markdown/emphasis_spacing.md) | Remove whitespace immediately inside emphasis delimiters. |
| [Markdown/EmphasisStyle](docs/cops/markdown/emphasis_style.md) | Use a configured or consistent emphasis delimiter. |
| [Markdown/EmptyLink](docs/cops/markdown/empty_link.md) | Require a nonempty link destination. |
| [Markdown/FenceBlankLines](docs/cops/markdown/fence_blank_lines.md) | Surround fenced code blocks with container-aware blank lines. |
| [Markdown/FenceLanguage](docs/cops/markdown/fence_language.md) | Require a language and optionally restrict fence languages. |
| [Markdown/FenceStyle](docs/cops/markdown/fence_style.md) | Use backtick, tilde, or consistently styled fences. |
| [Markdown/FirstHeading](docs/cops/markdown/first_heading.md) | Begin documents with a heading or front-matter title. |
| [Markdown/HardTabs](docs/cops/markdown/hard_tabs.md) | Disallow hard tabs with code-language exceptions. |
| [Markdown/HeadingBlankLines](docs/cops/markdown/heading_blank_lines.md) | Surround headings with blank lines. |
| [Markdown/HeadingIncrement](docs/cops/markdown/heading_increment.md) | Increase heading levels without skipping levels. |
| [Markdown/HeadingIndentation](docs/cops/markdown/heading_indentation.md) | Avoid leading indentation before headings. |
| [Markdown/HeadingPunctuation](docs/cops/markdown/heading_punctuation.md) | Avoid configured trailing heading punctuation. |
| [Markdown/HeadingStructure](docs/cops/markdown/heading_structure.md) | Match a configured exact heading outline. |
| [Markdown/HeadingStyle](docs/cops/markdown/heading_style.md) | Use a consistent heading syntax. |
| [Markdown/ImageAltText](docs/cops/markdown/image_alt_text.md) | Require nonblank Markdown image alternative text. |
| [Markdown/LinkFragment](docs/cops/markdown/link_fragment.md) | Validate local fragments using configurable heading anchors. |
| [Markdown/LinkStyle](docs/cops/markdown/link_style.md) | Configure permitted link and image styles independently. |
| [Markdown/LinkTextSpacing](docs/cops/markdown/link_text_spacing.md) | Remove leading and trailing whitespace from link text. |
| [Markdown/ListBlankLines](docs/cops/markdown/list_blank_lines.md) | Surround parsed lists with blank lines. |
| [Markdown/ListIndentation](docs/cops/markdown/list_indentation.md) | Keep sibling list markers consistently indented. |
| [Markdown/ListMarkerSpacing](docs/cops/markdown/list_marker_spacing.md) | Configure spaces after ordered and unordered list markers. |
| [Markdown/OrderedListNumbering](docs/cops/markdown/ordered_list_numbering.md) | Use sequential numbers or repeated ones in ordered lists. |
| [Markdown/ProperNames](docs/cops/markdown/proper_names.md) | Use configured capitalization for proper names. |
| [Markdown/RawHtml](docs/cops/markdown/raw_html.md) | Disallow raw HTML except explicitly allowed elements. |
| [Markdown/ReferenceDefinitions](docs/cops/markdown/reference_definitions.md) | Report unused and duplicate reference definitions. |
| [Markdown/ReversedLink](docs/cops/markdown/reversed_link.md) | Report reversed Markdown link delimiters. |
| [Markdown/ShellPrompts](docs/cops/markdown/shell_prompts.md) | Omit dollar prompts in shell-only examples without output. |
| [Markdown/SingleTopLevelHeading](docs/cops/markdown/single_top_level_heading.md) | Allow at most one top-level heading. |
| [Markdown/StrongStyle](docs/cops/markdown/strong_style.md) | Use a configured or consistent strong delimiter. |
| [Markdown/StructuralLineLength](docs/cops/markdown/structural_line_length.md) | Report overlong heading, code-block, and table source lines without reflowing them. |
| [Markdown/Syntax](docs/cops/markdown/syntax.md) | Report native Markdown parser diagnostics. |
| [Markdown/TableBlankLines](docs/cops/markdown/table_blank_lines.md) | Surround Markdown tables with blank lines. |
| [Markdown/TableColumns](docs/cops/markdown/table_columns.md) | Match table body column counts to the header. |
| [Markdown/TablePipes](docs/cops/markdown/table_pipes.md) | Use consistent leading and trailing table pipes. |
| [Markdown/TableSpacing](docs/cops/markdown/table_spacing.md) | Use configured spacing around table cell content. |
| [Markdown/ThematicBreakStyle](docs/cops/markdown/thematic_break_style.md) | Use a configured or consistent thematic break. |
| [Markdown/TrailingWhitespace](docs/cops/markdown/trailing_whitespace.md) | Remove trailing whitespace while retaining Markdown hard breaks. |
| [Markdown/UndefinedReference](docs/cops/markdown/undefined_reference.md) | Require definitions for link and image references. |
| [Markdown/UnorderedListIndentation](docs/cops/markdown/unordered_list_indentation.md) | Use a configured indentation width for unordered lists. |
| [Markdown/UnorderedListMarker](docs/cops/markdown/unordered_list_marker.md) | Use a configured or consistent unordered list marker. |
| [Prose/MaxLength](docs/cops/prose/max_length.md) | Wrap or unwrap prose paragraphs in Markdown and plain text. |
| [Prose/MultipleBlankLines](docs/cops/prose/multiple_blank_lines.md) | Limit consecutive blank lines outside code. |
| [Prose/TrailingNewline](docs/cops/prose/trailing_newline.md) | Require exactly one final newline. |

#### Settings

| Setting | Purpose |
| --- | --- |
| [Markdown/Include](docs/settings/files.md) | Select files parsed as Markdown using native RuboCop file patterns. |
| [Markdown/IgnoreFrontMatter](docs/settings/front_matter.md) | Ignore closed leading metadata during Markdown inspection. |

### Text

| Cop | Purpose |
| --- | ------- |
| [Prose/MaxLength](docs/cops/prose/max_length.md) | Wrap or unwrap prose paragraphs in Markdown and plain text. |
| [Prose/MultipleBlankLines](docs/cops/prose/multiple_blank_lines.md) | Limit consecutive blank lines outside code. |
| [Prose/TrailingNewline](docs/cops/prose/trailing_newline.md) | Require exactly one final newline. |
| [Text/TrailingWhitespace](docs/cops/text/trailing_whitespace.md) | Remove all trailing spaces and tabs from plain-text lines. |

#### Settings

| Setting | Purpose |
| --- | --- |
| [Text/Include](docs/settings/files.md) | Select files parsed as literal text using native RuboCop file patterns. |

## Project documentation

[CONTRIBUTING.md](CONTRIBUTING.md) covers development, testing, and artwork maintenance. [DESIGN.md](DESIGN.md) explains architecture and design decisions. [AGENTS.md](AGENTS.md) provides contributor instructions for coding agents.

## License

Released under the [MIT license](LICENSE.txt).
