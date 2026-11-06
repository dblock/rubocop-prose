# Upgrading

Breaking changes are grouped by target release; follow the linked cop guides for configuration examples.

## From 0.1.0 To 0.2.0

- Rename this plugin's `Markdown/Syntax` configuration to [`Markdown/KramdownSyntax`](docs/cops/markdown/kramdown_syntax.md#migrating-from-010); `rubocop-md` now owns `Markdown/Syntax`.
- Replace `EnforcedStyle` with `Style` in [`Markdown/CodeBlockStyle`](docs/cops/markdown/code_block_style.md#migrating-from-010).
- Replace `EnforcedStyle` with `Style` in [`Markdown/FenceStyle`](docs/cops/markdown/fence_style.md#migrating-from-010).
- Replace `EnforcedStyle` with `Style` in [`Markdown/HeadingStyle`](docs/cops/markdown/heading_style.md#migrating-from-010).
- Replace `EnforcedStyle` with `Style` in [`Markdown/OrderedListNumbering`](docs/cops/markdown/ordered_list_numbering.md#migrating-from-010).
- Replace `EnforcedStyle` with `Style` in [`Markdown/UnorderedListMarker`](docs/cops/markdown/unordered_list_marker.md#migrating-from-010).
- Replace `OrderedSingle`, `OrderedMulti`, `UnorderedSingle`, and `UnorderedMulti` with shared `Style` and `MinSpaces` in [`Markdown/ListMarkerSpacing`](docs/cops/markdown/list_marker_spacing.md#migrating-from-010).
- Replace shared `Max` and enable/value pairs with integer widths or `false` for `Headings`, `CodeBlocks`, and `Tables` in [`Markdown/StructuralLineLength`](docs/cops/markdown/structural_line_length.md#migrating-from-010).
- Replace `CheckDuplicates` and `AllowIdenticalDuplicates` with `Duplicates`, and rename `CheckUnused` to `Unused` in [`Markdown/ReferenceDefinitions`](docs/cops/markdown/reference_definitions.md#migrating-from-010).
- Replace `FrontMatterTitle: true` and `TitleKey` with `FrontMatterTitle: <metadata key>` (or `false`) in [`Markdown/FirstHeading`](docs/cops/markdown/first_heading.md#migrating-from-010).
