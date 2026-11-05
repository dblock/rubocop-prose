<img src="assets/logo.gif" alt="The RuboCop helmet logo alongside a parchment scroll rolling up and unfurling." width="160">

# rubocop-prose

[![Gem Version](https://badge.fury.io/rb/rubocop-prose.svg)](https://rubygems.org/gems/rubocop-prose) [![Lint](https://github.com/dblock/rubocop-prose/actions/workflows/lint.yml/badge.svg?branch=main)](https://github.com/dblock/rubocop-prose/actions/workflows/lint.yml) [![Tests](https://github.com/dblock/rubocop-prose/actions/workflows/test.yml/badge.svg?branch=main)](https://github.com/dblock/rubocop-prose/actions/workflows/test.yml) [![Coverage Status](https://coveralls.io/repos/github/dblock/rubocop-prose/badge.svg?branch=main)](https://coveralls.io/github/dblock/rubocop-prose?branch=main)

Markdown and plain-text prose checks for RuboCop.

Use [rubocop-md](https://github.com/rubocop/rubocop-md) to lint Ruby code inside Markdown.

This project was inspired by [To Wrap or Not to Wrap in Markdown](https://code.dblock.org/2021/06/07/to-wrap-or-not-to-wrap-in-markdown.html) and borrows many Markdown checks from [markdownlint](https://github.com/DavidAnson/markdownlint).

## Installation

Add to your Gemfile, then run `bundle install`:

```ruby
gem 'rubocop-prose', '~> 0.1', require: false
```

Add it to `.rubocop.yml` using RuboCop's plugin interface:

```yaml
plugins:
  - rubocop-prose
```

Ruby 3.2 or newer and RuboCop 1.72.1 or newer within 1.x are supported.

## Usage

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

## Cops

### Markdown

Markdown checks ignore [front matter](docs/settings/front_matter.md) by default and do not treat code blocks as prose. Dedicated code-block cops check their structure; [Markdown/HardTabs](docs/cops/markdown/hard_tabs.md) and [Markdown/StructuralLineLength](docs/cops/markdown/structural_line_length.md) can also inspect code content. Inline formatting checks leave code spans, links, escaped syntax, and HTML untouched unless they specifically check those constructs.

| Cop                                                                                         | Default  | Purpose                                                                             |
| ---                                                                                         | ---      | -------                                                                             |
| [Markdown/AtxHeadingSpace](docs/cops/markdown/atx_heading_space.md)                         | Enabled  | Separate opening ATX heading hashes from text.                                      |
| [Markdown/AtxHeadingSpacing](docs/cops/markdown/atx_heading_spacing.md)                     | Enabled  | Use one space after opening ATX heading hashes.                                     |
| [Markdown/BareUrl](docs/cops/markdown/bare_url.md)                                          | Disabled | Require Markdown links or autolinks around bare URLs.                               |
| [Markdown/BlockquoteBlankLines](docs/cops/markdown/blockquote_blank_lines.md)               | Enabled  | Keep quote markers on blank lines between blockquotes.                              |
| [Markdown/BlockquoteSpacing](docs/cops/markdown/blockquote_spacing.md)                      | Enabled  | Use one space after nonempty blockquote markers.                                    |
| [Markdown/ClosedHeadingSpace](docs/cops/markdown/closed_heading_space.md)                   | Enabled  | Separate closing ATX heading hashes from text.                                      |
| [Markdown/ClosedHeadingSpacing](docs/cops/markdown/closed_heading_spacing.md)               | Enabled  | Use one space before closing ATX heading hashes.                                    |
| [Markdown/CompactLists](docs/cops/markdown/compact_lists.md)                                | Enabled  | Avoid blank lines between simple list items.                                        |
| [Markdown/CodeBlockStyle](docs/cops/markdown/code_block_style.md)                           | Disabled | Use fenced, indented, or consistently styled code blocks.                           |
| [Markdown/CodeSpanSpacing](docs/cops/markdown/code_span_spacing.md)                         | Enabled  | Avoid unnecessary padding inside inline code.                                       |
| [Markdown/DescriptiveLinkText](docs/cops/markdown/descriptive_link_text.md)                 | Enabled  | Require descriptive link text instead of generic labels.                            |
| [Markdown/DuplicateHeadings](docs/cops/markdown/duplicate_headings.md)                      | Enabled  | Avoid duplicate heading text.                                                       |
| [Markdown/EmphasisHeading](docs/cops/markdown/emphasis_heading.md)                          | Disabled | Avoid single-line emphasis-only paragraphs in place of headings.                    |
| [Markdown/EmphasisSpacing](docs/cops/markdown/emphasis_spacing.md)                          | Enabled  | Remove whitespace immediately inside emphasis delimiters.                           |
| [Markdown/EmphasisStyle](docs/cops/markdown/emphasis_style.md)                              | Enabled  | Use a configured or consistent emphasis delimiter.                                  |
| [Markdown/EmptyLink](docs/cops/markdown/empty_link.md)                                      | Enabled  | Require a nonempty link destination.                                                |
| [Markdown/FenceBlankLines](docs/cops/markdown/fence_blank_lines.md)                         | Enabled  | Surround fenced code blocks with container-aware blank lines.                       |
| [Markdown/FenceLanguage](docs/cops/markdown/fence_language.md)                              | Enabled  | Require a language and optionally restrict fence languages.                         |
| [Markdown/FenceStyle](docs/cops/markdown/fence_style.md)                                    | Enabled  | Use backtick, tilde, or consistently styled fences.                                 |
| [Markdown/FirstHeading](docs/cops/markdown/first_heading.md)                                | Disabled | Begin documents with a heading or front-matter title.                               |
| [Markdown/FrontMatterKeys](docs/cops/markdown/front_matter_keys.md)                         | Disabled | Restrict allowed and require mandatory top-level front matter keys.                 |
| [Markdown/FrontMatterSyntax](docs/cops/markdown/front_matter_syntax.md)                     | Enabled  | Report YAML syntax errors in closed leading front matter.                           |
| [Markdown/HardBreakStyle](docs/cops/markdown/hard_break_style.md)                           | Enabled  | Use backslashes or trailing spaces for paragraph hard breaks.                       |
| [Markdown/HardTabs](docs/cops/markdown/hard_tabs.md)                                        | Enabled  | Disallow hard tabs with code-language exceptions.                                   |
| [Markdown/HeadingBlankLines](docs/cops/markdown/heading_blank_lines.md)                     | Enabled  | Surround headings with blank lines.                                                 |
| [Markdown/HeadingCapitalization](docs/cops/markdown/heading_capitalization.md)              | Disabled | Enforce initial capitalization or title case in headings.                           |
| [Markdown/HeadingIncrement](docs/cops/markdown/heading_increment.md)                        | Enabled  | Increase heading levels without skipping levels.                                    |
| [Markdown/HeadingIndentation](docs/cops/markdown/heading_indentation.md)                    | Enabled  | Avoid leading indentation before headings.                                          |
| [Markdown/HeadingPunctuation](docs/cops/markdown/heading_punctuation.md)                    | Disabled | Avoid configured trailing heading punctuation.                                      |
| [Markdown/HeadingStructure](docs/cops/markdown/heading_structure.md)                        | Disabled | Match a configured exact heading outline.                                           |
| [Markdown/HeadingStyle](docs/cops/markdown/heading_style.md)                                | Disabled | Use a consistent heading syntax.                                                    |
| [Markdown/ImageAltText](docs/cops/markdown/image_alt_text.md)                               | Enabled  | Require nonblank Markdown image alternative text.                                   |
| [Markdown/ImagePathSeparators](docs/cops/markdown/image_path_separators.md)                 | Enabled  | Use forward slashes in local image destinations.                                    |
| [Markdown/LinkFragment](docs/cops/markdown/link_fragment.md)                                | Disabled | Validate local fragments using configurable heading anchors.                        |
| [Markdown/LinkStyle](docs/cops/markdown/link_style.md)                                      | Disabled | Configure permitted link and image styles independently.                            |
| [Markdown/LinkTextSpacing](docs/cops/markdown/link_text_spacing.md)                         | Enabled  | Remove leading and trailing whitespace from link text.                              |
| [Markdown/ListBlankLines](docs/cops/markdown/list_blank_lines.md)                           | Enabled  | Surround parsed lists with blank lines.                                             |
| [Markdown/ListContinuationIndentation](docs/cops/markdown/list_continuation_indentation.md) | Enabled  | Indent list continuation text to its item's content column.                         |
| [Markdown/ListIndentation](docs/cops/markdown/list_indentation.md)                          | Enabled  | Keep sibling list markers consistently indented.                                    |
| [Markdown/ListItemCapitalization](docs/cops/markdown/list_item_capitalization.md)           | Disabled | Enforce consistent initials, initial capitals, or title case in list items.         |
| [Markdown/ListItemPunctuation](docs/cops/markdown/list_item_punctuation.md)                 | Disabled | Require, forbid, or consistently use terminal punctuation in list items.            |
| [Markdown/ListMarkerSpacing](docs/cops/markdown/list_marker_spacing.md)                     | Enabled  | Configure spaces after ordered and unordered list markers.                          |
| [Markdown/OrderedListNumbering](docs/cops/markdown/ordered_list_numbering.md)               | Disabled | Use sequential numbers or repeated ones in ordered lists.                           |
| [Markdown/OutsideSpacing](docs/cops/markdown/outside_spacing.md)                            | Enabled  | Report inline formatting directly adjacent to prose words.                          |
| [Markdown/ProperNames](docs/cops/markdown/proper_names.md)                                  | Disabled | Use configured capitalization for proper names.                                     |
| [Markdown/RawHtml](docs/cops/markdown/raw_html.md)                                          | Disabled | Disallow raw HTML except allowed elements, with optional attribute allowlists.      |
| [Markdown/ReferenceDefinitions](docs/cops/markdown/reference_definitions.md)                | Enabled  | Report unused and duplicate reference definitions.                                  |
| [Markdown/ReversedLink](docs/cops/markdown/reversed_link.md)                                | Enabled  | Report reversed Markdown link delimiters.                                           |
| [Markdown/ShellPrompts](docs/cops/markdown/shell_prompts.md)                                | Enabled  | Omit configured shell prompts in examples without output.                           |
| [Markdown/SingleTopLevelHeading](docs/cops/markdown/single_top_level_heading.md)            | Disabled | Allow at most one top-level heading.                                                |
| [Markdown/StrongStyle](docs/cops/markdown/strong_style.md)                                  | Enabled  | Use a configured or consistent strong delimiter.                                    |
| [Markdown/StructuralLineLength](docs/cops/markdown/structural_line_length.md)               | Disabled | Report overlong heading, code-block, and table source lines without reflowing them. |
| [Markdown/Syntax](docs/cops/markdown/syntax.md)                                             | Enabled  | Report native Markdown parser diagnostics.                                          |
| [Markdown/TableBlankLines](docs/cops/markdown/table_blank_lines.md)                         | Enabled  | Surround Markdown tables with blank lines.                                          |
| [Markdown/TableColumns](docs/cops/markdown/table_columns.md)                                | Enabled  | Match table body column counts to the header.                                       |
| [Markdown/TablePipes](docs/cops/markdown/table_pipes.md)                                    | Enabled  | Use consistent leading and trailing table pipes.                                    |
| [Markdown/TableSpacing](docs/cops/markdown/table_spacing.md)                                | Enabled  | Use configured spacing around table cell content.                                   |
| [Markdown/ThematicBreakBlankLines](docs/cops/markdown/thematic_break_blank_lines.md)        | Enabled  | Surround parsed thematic breaks with container-aware blank lines.                   |
| [Markdown/ThematicBreakStyle](docs/cops/markdown/thematic_break_style.md)                   | Enabled  | Use a configured or consistent thematic break.                                      |
| [Markdown/TrailingWhitespace](docs/cops/markdown/trailing_whitespace.md)                    | Enabled  | Remove trailing whitespace while retaining Markdown hard breaks.                    |
| [Markdown/UnclosedFencedCodeBlock](docs/cops/markdown/unclosed_fenced_code_block.md)        | Enabled  | Require an explicit closing fence for fenced code blocks.                           |
| [Markdown/UndefinedReference](docs/cops/markdown/undefined_reference.md)                    | Enabled  | Require definitions for link and image references.                                  |
| [Markdown/UnorderedListIndentation](docs/cops/markdown/unordered_list_indentation.md)       | Enabled  | Use a configured indentation width for unordered lists.                             |
| [Markdown/UnorderedListMarker](docs/cops/markdown/unordered_list_marker.md)                 | Enabled  | Use a configured or consistent unordered list marker.                               |
| [Prose/MaxLength](docs/cops/prose/max_length.md)                                            | Enabled  | Wrap or unwrap prose paragraphs in Markdown and plain text.                         |
| [Prose/MultipleBlankLines](docs/cops/prose/multiple_blank_lines.md)                         | Enabled  | Limit blank lines in prose and quotes, but not code.                                |
| [Prose/TrailingNewline](docs/cops/prose/trailing_newline.md)                                | Enabled  | Require exactly one final newline.                                                  |

#### Settings

| Setting                                                     | Purpose                                                             |
| ---                                                         | ---                                                                 |
| [Markdown/Include](docs/settings/files.md)                  | Select files parsed as Markdown using native RuboCop file patterns. |
| [Markdown/IgnoreFrontMatter](docs/settings/front_matter.md) | Ignore closed leading metadata during Markdown inspection.          |

### Text

| Cop                                                                 | Default | Purpose                                                     |
| ---                                                                 | ---     | -------                                                     |
| [Prose/MaxLength](docs/cops/prose/max_length.md)                    | Enabled | Wrap or unwrap prose paragraphs in Markdown and plain text. |
| [Prose/MultipleBlankLines](docs/cops/prose/multiple_blank_lines.md) | Enabled | Limit consecutive literal blank lines.                      |
| [Prose/TrailingNewline](docs/cops/prose/trailing_newline.md)        | Enabled | Require exactly one final newline.                          |
| [Text/TrailingWhitespace](docs/cops/text/trailing_whitespace.md)    | Enabled | Remove all trailing spaces and tabs from plain-text lines.  |

#### Settings

| Setting                                | Purpose                                                                 |
| ---                                    | ---                                                                     |
| [Text/Include](docs/settings/files.md) | Select files parsed as literal text using native RuboCop file patterns. |

## Project Documentation

See [CONTRIBUTING](CONTRIBUTING.md) for development, testing, and artwork maintenance, [DESIGN](DESIGN.md) for architecture and design decisions, and [AGENTS](AGENTS.md) for contributor instructions for coding agents.

## License

Released under the [MIT license](LICENSE.txt).
