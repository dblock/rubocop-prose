# Prose/HeadingIncrement

Related rule: MD001. Disabled by default.

Reports a parsed heading whose level increases by more than one from the preceding heading, for example `# Title` followed by `### Detail`; decreases and an initial heading at any level are allowed.

ATX, closed ATX and Setext headings participate, including parsed container headings; fenced code, indented code, escaped markers and front matter do not. This uses the project's GFM parser rather than promising markdownlint-identical parsing.

Report-only: choosing a replacement heading level would change the document structure.
