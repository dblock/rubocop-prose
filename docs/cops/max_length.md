# Prose/MaxLength

Opt-in paragraph formatting. `Max` is a positive character count (default `80`), including source container prefixes, or `false` to keep each paragraph on one source line. Autocorrection wraps at whitespace, preserves list/blockquote prefixes, and does not split links, inline code, HTML atoms, escapes, or task-list markers. Code blocks, front matter, tables, and headings are never reformatted by paragraph corrections.

Unbreakable tokens can remain over the limit and report without a usable correction.

With `Max: false`, soft source line breaks are joined with one space. Blank lines still separate paragraphs, and Markdown hard breaks, `<br>` boundaries, multiline inline code, and HTML-only blocks retain their semantics.

For source-length policies, `Headings` defaults to `true`, while `CodeBlocks` and `Tables` default to `false`. Enable those contexts to report their overlong source lines without autocorrecting structural content. `HeadingMax` and `CodeBlockMax` optionally override `Max`; `null` inherits it. Table delimiter lines count as table source. `IgnoreURLs: true` ignores paragraph lines containing only one URL; disable it for strict URL reporting. These structural policies are inactive in paragraph-unwrapping mode.

## Examples

For this configuration:

```yaml
Prose/MaxLength:
  Enabled: true
  Max: false
```

### Bad

```markdown
A paragraph split
across two source lines.
```

### Good

```markdown
A paragraph split across two source lines.
```
