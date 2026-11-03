# Default policy

Most cops are enabled by default to catch broken Markdown, inconsistent formatting, and common prose whitespace problems. The [cops section](../../README.md#cops) lists all available checks; each cop's guide documents its default. All enabled cops remain individually configurable.

The following cops are opt-in because they impose project-specific, editorial, or renderer-dependent policies:

| Cop | Why it is opt-in |
| --- | --- |
| [Prose/MaxLength](../cops/prose/max_length.md) | Wrapping or unwrapping paragraphs is a source-layout preference. |
| [Markdown/StructuralLineLength](../cops/markdown/structural_line_length.md) | Structural line limits depend on project layout and tooling. |
| [Markdown/FirstHeading](../cops/markdown/first_heading.md) | Fragments and included documents do not always need an opening heading. |
| [Markdown/SingleTopLevelHeading](../cops/markdown/single_top_level_heading.md) | Documents can legitimately contain multiple top-level sections. |
| [Markdown/HeadingStructure](../cops/markdown/heading_structure.md) | Required outlines belong to project templates. |
| [Markdown/HeadingPunctuation](../cops/markdown/heading_punctuation.md) | Questions and other punctuated headings can be intentional. |
| [Markdown/HeadingStyle](../cops/markdown/heading_style.md) | Mixing ATX and Setext headings is valid Markdown. |
| [Markdown/EmphasisHeading](../cops/markdown/emphasis_heading.md) | Standalone emphasis can be a label or callout rather than a heading. |
| [Markdown/ProperNames](../cops/markdown/proper_names.md) | Canonical spellings require a project-specific dictionary. |
| [Markdown/RawHtml](../cops/markdown/raw_html.md) | HTML is useful for details, anchors, images, and other supported markup. |
| [Markdown/BareUrl](../cops/markdown/bare_url.md) | Many renderers intentionally autolink bare URLs. |
| [Markdown/LinkFragment](../cops/markdown/link_fragment.md) | Heading anchors and explicit IDs depend on the renderer. |
| [Markdown/LinkStyle](../cops/markdown/link_style.md) | Inline, reference, and autolink styles are all valid choices. |
| [Markdown/OrderedListNumbering](../cops/markdown/ordered_list_numbering.md) | Repeated and sequential source numbering are both legitimate. |
| [Markdown/CodeBlockStyle](../cops/markdown/code_block_style.md) | Both fenced and indented code blocks are valid. |
| [Markdown/ShellPrompts](../cops/markdown/shell_prompts.md) | Prompts can intentionally distinguish commands from output. |

Enabled cops also use conservative settings: `Markdown/HardTabs` ignores code blocks, `Markdown/DuplicateHeadings` checks duplicates among siblings, and `Markdown/ReferenceDefinitions` reports duplicate definitions without requiring unused definitions to be removed.

## Example

Enable an optional policy or disable an enabled cop using normal RuboCop configuration:

```yaml
Prose/MaxLength:
  Enabled: true
  Max: false
Markdown/FenceLanguage:
  Enabled: false
```
