# Prose/HeadingBlankLines

Related rule: MD022. Disabled by default.

`LinesAbove` and `LinesBelow` set minimum blank-line counts, both defaulting to `1`; `0` disables the respective requirement. Boundaries of the document and the end of front matter do not require padding.

Checks parsed ATX and Setext headings, measuring after the underline for Setext syntax. Whitespace-only and blockquote-marker-only lines count as blank; fenced and indented code are not headings. Container boundaries are inspected as physical source lines rather than reproducing markdownlint container semantics.

Report-only: adding blank lines can change lists, blockquotes and paragraph interpretation.
