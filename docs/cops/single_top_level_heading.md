# Prose/SingleTopLevelHeading

Related rule: MD025. Disabled by default.

`Level` selects the top-level heading level and defaults to `1`. Every parsed heading at that level after the first is reported; documents without one are allowed.

Both ATX and Setext headings count, including parsed container headings. Unlike markdownlint's front-matter integration, front-matter titles do not count as headings for this cop; use `Prose/FirstHeading` for a front-matter title policy. Code and escaped markers do not count.

Report-only: removing or demoting a heading changes document structure.
