# Changelog

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 0.2.0 (Next)

- [#126](https://github.com/dblock/rubocop-prose/pull/126): Report unit and integration test coverage to Coveralls - [@dblock](https://github.com/dblock).
- [#138](https://github.com/dblock/rubocop-prose/pull/138): Add opt-in `Markdown/ListItemPunctuation` to check punctuation presence across sibling list items - [@dblock](https://github.com/dblock).
- [#139](https://github.com/dblock/rubocop-prose/pull/139): Add an opt-in exception for a single trailing space on empty Markdown blockquote lines, including nested quotes - [@dblock](https://github.com/dblock).
- Your contribution here.

## 0.1.0 (2026/11/03)

- [#120](https://github.com/dblock/rubocop-prose/pull/120): Add a default-enabled Markdown hard-break style policy with backslash and trailing-space syntax options - [@dblock](https://github.com/dblock).
- [#110](https://github.com/dblock/rubocop-prose/pull/110): Add enabled-by-default `Markdown/ListContinuationIndentation` to report lazy list continuation text outside its item's content column - [@dblock](https://github.com/dblock).
- [#114](https://github.com/dblock/rubocop-prose/pull/114): Add the default-enabled `Markdown/UnclosedFencedCodeBlock` report for EOF-terminated fenced code blocks - [@dblock](https://github.com/dblock).
- [#108](https://github.com/dblock/rubocop-prose/pull/108): Allow multiple explicit thematic-break spellings with report-only handling for ambiguous corrections - [@dblock](https://github.com/dblock).
- [#107](https://github.com/dblock/rubocop-prose/pull/107): Apply the configured blank-line limit inside Markdown blockquotes while preserving quote markers and paragraph separation - [@dblock](https://github.com/dblock).
- [#109](https://github.com/dblock/rubocop-prose/pull/109): Add default-enabled compact-list spacing checks with safe correction for simple items - [@dblock](https://github.com/dblock).
- [#112](https://github.com/dblock/rubocop-prose/pull/112): Detect and safely correct missing separators after blockquote markers - [@dblock](https://github.com/dblock).
- [#111](https://github.com/dblock/rubocop-prose/pull/111): Add default-enabled `Markdown/OutsideSpacing` for inline formatting adjacent to prose - [@dblock](https://github.com/dblock).
- [#113](https://github.com/dblock/rubocop-prose/pull/113): Add `Markdown/ThematicBreakBlankLines` for default-enabled, container-aware spacing around parsed thematic breaks - [@dblock](https://github.com/dblock).
- [#115](https://github.com/dblock/rubocop-prose/pull/115): Add a default-enabled check for backslash separators in local Markdown image paths - [@dblock](https://github.com/dblock).
- [#106](https://github.com/dblock/rubocop-prose/pull/106): Enable dollar and percent shell-prompt cleanup with configurable markers and report-only handling of ambiguous shell comments - [@dblock](https://github.com/dblock).
- [#75](https://github.com/dblock/rubocop-prose/pull/75): Configure independent blank-line counts above and below fenced code blocks - [@dblock](https://github.com/dblock).
- [#72](https://github.com/dblock/rubocop-prose/pull/72): Allow identical reference definitions while retaining conflict and unused checks - [@dblock](https://github.com/dblock).
- [#69](https://github.com/dblock/rubocop-prose/pull/69): Add reproducible prose benchmarks and share Markdown document analysis across cops - [@dblock](https://github.com/dblock).
- [#66](https://github.com/dblock/rubocop-prose/pull/66): Enable common-sense Markdown and text checks and unwrapped paragraphs by default, with conservative heading, tab, and reference policies - [@dblock](https://github.com/dblock).
- [#65](https://github.com/dblock/rubocop-prose/pull/65): Configure Markdown and text Include patterns with per-file discovery, source dispatch, and a README settings catalog - [@dblock](https://github.com/dblock).
- [#63](https://github.com/dblock/rubocop-prose/pull/63): Add plain-text support with shared Prose, Markdown, and Text departments, format-specific policies, and grouped integration tests - [@dblock](https://github.com/dblock).
- [#60](https://github.com/dblock/rubocop-prose/pull/60): Add a RuboCop-inspired logo with a parchment scroll, editable SVG artwork, and a README image - [@dblock](https://github.com/dblock).
- [#58](https://github.com/dblock/rubocop-prose/pull/58): Add `Prose/TableSpacing` for table cell spacing - [@dblock](https://github.com/dblock).
- [#57](https://github.com/dblock/rubocop-prose/pull/57): Add `Prose/TableBlankLines` for blank lines around tables - [@dblock](https://github.com/dblock).
- [#56](https://github.com/dblock/rubocop-prose/pull/56): Add `Prose/TableColumns` for consistent table column counts - [@dblock](https://github.com/dblock).
- [#55](https://github.com/dblock/rubocop-prose/pull/55): Add `Prose/TablePipes` for table pipe style - [@dblock](https://github.com/dblock).
- [#54](https://github.com/dblock/rubocop-prose/pull/54): Add `Prose/StrongStyle` for consistent strong-emphasis delimiters - [@dblock](https://github.com/dblock).
- [#53](https://github.com/dblock/rubocop-prose/pull/53): Add `Prose/EmphasisStyle` for consistent emphasis delimiters - [@dblock](https://github.com/dblock).
- [#52](https://github.com/dblock/rubocop-prose/pull/52): Add `Prose/ProperNames` for configured proper-name capitalization - [@dblock](https://github.com/dblock).
- [#51](https://github.com/dblock/rubocop-prose/pull/51): Add `Prose/CodeSpanSpacing` for spacing inside inline code spans - [@dblock](https://github.com/dblock).
- [#50](https://github.com/dblock/rubocop-prose/pull/50): Add `Prose/EmphasisSpacing` for spacing inside emphasis markers - [@dblock](https://github.com/dblock).
- [#49](https://github.com/dblock/rubocop-prose/pull/49): Add `Prose/ThematicBreakStyle` for consistent thematic breaks - [@dblock](https://github.com/dblock).
- [#48](https://github.com/dblock/rubocop-prose/pull/48): Add `Prose/RawHtml` for configurable inline HTML restrictions - [@dblock](https://github.com/dblock).
- [#47](https://github.com/dblock/rubocop-prose/pull/47): Add `Prose/DescriptiveLinkText` for descriptive link labels - [@dblock](https://github.com/dblock).
- [#46](https://github.com/dblock/rubocop-prose/pull/46): Add `Prose/LinkStyle` for allowed link and image styles - [@dblock](https://github.com/dblock).
- [#45](https://github.com/dblock/rubocop-prose/pull/45): Add `Prose/ReferenceDefinitions` for duplicate and unused reference definitions - [@dblock](https://github.com/dblock).
- [#44](https://github.com/dblock/rubocop-prose/pull/44): Add `Prose/UndefinedReference` for undefined link and image references - [@dblock](https://github.com/dblock).
- [#43](https://github.com/dblock/rubocop-prose/pull/43): Add `Prose/LinkFragment` for local heading-fragment targets - [@dblock](https://github.com/dblock).
- [#42](https://github.com/dblock/rubocop-prose/pull/42): Add `Prose/ImageAltText` for missing image alternative text - [@dblock](https://github.com/dblock).
- [#41](https://github.com/dblock/rubocop-prose/pull/41): Add `Prose/EmptyLink` for empty link destinations - [@dblock](https://github.com/dblock).
- [#40](https://github.com/dblock/rubocop-prose/pull/40): Add `Prose/LinkTextSpacing` for spacing inside link text - [@dblock](https://github.com/dblock).
- [#39](https://github.com/dblock/rubocop-prose/pull/39): Add `Prose/BareUrl` for bare URLs outside code and other protected spans - [@dblock](https://github.com/dblock).
- [#38](https://github.com/dblock/rubocop-prose/pull/38): Add `Prose/ReversedLink` for reversed link syntax - [@dblock](https://github.com/dblock).
- [#37](https://github.com/dblock/rubocop-prose/pull/37): Add `Prose/FenceStyle` for consistent code-fence markers - [@dblock](https://github.com/dblock).
- [#36](https://github.com/dblock/rubocop-prose/pull/36): Add `Prose/CodeBlockStyle` for fenced or indented code-block style - [@dblock](https://github.com/dblock).
- [#35](https://github.com/dblock/rubocop-prose/pull/35): Add `Prose/FenceLanguage` for code-fence language identifiers - [@dblock](https://github.com/dblock).
- [#34](https://github.com/dblock/rubocop-prose/pull/34): Add `Prose/FenceBlankLines` for blank lines around fenced code blocks - [@dblock](https://github.com/dblock).
- [#33](https://github.com/dblock/rubocop-prose/pull/33): Add `Prose/ShellPrompts` for unnecessary shell prompts in command examples - [@dblock](https://github.com/dblock).
- [#32](https://github.com/dblock/rubocop-prose/pull/32): Add `Prose/ListBlankLines` for blank lines around lists - [@dblock](https://github.com/dblock).
- [#31](https://github.com/dblock/rubocop-prose/pull/31): Add `Prose/ListMarkerSpacing` for spacing after list markers - [@dblock](https://github.com/dblock).
- [#30](https://github.com/dblock/rubocop-prose/pull/30): Add `Prose/OrderedListNumbering` for ordered-list numbering styles - [@dblock](https://github.com/dblock).
- [#29](https://github.com/dblock/rubocop-prose/pull/29): Add `Prose/BlockquoteBlankLines` for blank lines within blockquotes - [@dblock](https://github.com/dblock).
- [#28](https://github.com/dblock/rubocop-prose/pull/28): Add `Prose/BlockquoteSpacing` for spacing after blockquote markers - [@dblock](https://github.com/dblock).
- [#27](https://github.com/dblock/rubocop-prose/pull/27): Add `Prose/UnorderedListIndentation` for nested unordered-list indentation - [@dblock](https://github.com/dblock).
- [#26](https://github.com/dblock/rubocop-prose/pull/26): Add `Prose/ListIndentation` for consistent list-item indentation - [@dblock](https://github.com/dblock).
- [#25](https://github.com/dblock/rubocop-prose/pull/25): Add `Prose/UnorderedListMarker` for unordered-list marker styles - [@dblock](https://github.com/dblock).
- [#24](https://github.com/dblock/rubocop-prose/pull/24): Add `Prose/HeadingStructure` for a configured heading outline - [@dblock](https://github.com/dblock).
- [#23](https://github.com/dblock/rubocop-prose/pull/23): Add `Prose/FirstHeading` for the initial heading level and optional front-matter title exemption - [@dblock](https://github.com/dblock).
- [#22](https://github.com/dblock/rubocop-prose/pull/22): Add `Prose/EmphasisHeading` for emphasis-only paragraphs used as headings - [@dblock](https://github.com/dblock).
- [#21](https://github.com/dblock/rubocop-prose/pull/21): Add `Prose/HeadingPunctuation` for trailing heading punctuation - [@dblock](https://github.com/dblock).
- [#20](https://github.com/dblock/rubocop-prose/pull/20): Add `Prose/SingleTopLevelHeading` for multiple top-level headings - [@dblock](https://github.com/dblock).
- [#19](https://github.com/dblock/rubocop-prose/pull/19): Add `Prose/DuplicateHeadings` for duplicate headings in document or sibling scope - [@dblock](https://github.com/dblock).
- [#18](https://github.com/dblock/rubocop-prose/pull/18): Add `Prose/HeadingIndentation` for leading heading indentation - [@dblock](https://github.com/dblock).
- [#17](https://github.com/dblock/rubocop-prose/pull/17): Add `Prose/HeadingBlankLines` for blank lines around headings - [@dblock](https://github.com/dblock).
- [#16](https://github.com/dblock/rubocop-prose/pull/16): Add `Prose/ClosedHeadingSpacing` for excess spacing before closing heading hashes - [@dblock](https://github.com/dblock).
- [#15](https://github.com/dblock/rubocop-prose/pull/15): Add `Prose/ClosedHeadingSpace` for missing spacing before closing heading hashes - [@dblock](https://github.com/dblock).
- [#14](https://github.com/dblock/rubocop-prose/pull/14): Add `Prose/AtxHeadingSpacing` for excess spacing after opening heading hashes - [@dblock](https://github.com/dblock).
- [#13](https://github.com/dblock/rubocop-prose/pull/13): Add `Prose/AtxHeadingSpace` for missing spacing after opening heading hashes - [@dblock](https://github.com/dblock).
- [#12](https://github.com/dblock/rubocop-prose/pull/12): Add `Prose/HeadingStyle` for consistent ATX, closed ATX, or Setext headings - [@dblock](https://github.com/dblock).
- [#11](https://github.com/dblock/rubocop-prose/pull/11): Add `Prose/HeadingIncrement` for skipped heading levels - [@dblock](https://github.com/dblock).
- [#10](https://github.com/dblock/rubocop-prose/pull/10): Add `Prose/TrailingNewline` to normalize the final document newline - [@dblock](https://github.com/dblock).
- [#9](https://github.com/dblock/rubocop-prose/pull/9): Add `Prose/MultipleBlankLines` to limit consecutive blank lines without merging paragraphs - [@dblock](https://github.com/dblock).
- [#8](https://github.com/dblock/rubocop-prose/pull/8): Add `Prose/HardTabs` with code-language exceptions - [@dblock](https://github.com/dblock).
- [#7](https://github.com/dblock/rubocop-prose/pull/7): Add `Prose/TrailingWhitespace`, preserving Markdown hard breaks - [@dblock](https://github.com/dblock).
- [#6](https://github.com/dblock/rubocop-prose/pull/6): Extend line-length policies to headings, code blocks, and tables - [@dblock](https://github.com/dblock).
- [#5](https://github.com/dblock/rubocop-prose/pull/5): Add shared configurable front-matter exclusion - [@dblock](https://github.com/dblock).
- [#4](https://github.com/dblock/rubocop-prose/pull/4): Add `Prose/Syntax` to report parser diagnostics without duplicate reference reports - [@dblock](https://github.com/dblock).
- [#3](https://github.com/dblock/rubocop-prose/pull/3): Add single-line paragraph unwrapping and CLI integration - [@dblock](https://github.com/dblock).
- [#2](https://github.com/dblock/rubocop-prose/pull/2): Add `Prose/MaxLength` for safe Markdown paragraph wrapping - [@dblock](https://github.com/dblock).
- [#1](https://github.com/dblock/rubocop-prose/pull/1): Add the parser-backed RuboCop plugin foundation with original-source ranges and opt-in document cops - [@dblock](https://github.com/dblock).
