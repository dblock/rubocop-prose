# Prose/TrailingWhitespace

Opt-in MD009-style trailing whitespace checks. `HardBreakSpaces` defaults to `2` and accepts integers of at least two. Paragraph hard breaks are retained and normalized to that width; stray spaces, tabs, and whitespace-only lines are trimmed. Heading spacing is not mistaken for a paragraph hard break.

`CodeBlocks` defaults to `false`. When enabled, code whitespace is report-only because removing spaces inside embedded strings can change code behavior. Front matter follows the shared setting. Unlike markdownlint, configuring zero hard-break spaces is rejected rather than silently deleting rendered breaks.
