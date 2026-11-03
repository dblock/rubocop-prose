# Prose/UnorderedListMarker

Opt-in counterpart of MD004. `EnforcedStyle` is `consistent` (the default), `asterisk`, `plus`, or `dash`. Consistent mode uses the first parsed unordered list marker throughout the document, including nested lists and blockquotes.

Only parsed list items are checked; escaped markers, front matter, thematic breaks, and code are ignored. Corrections replace only the marker; replacements that could create a thematic break are report-only. Unlike markdownlint, a different marker per nesting level (`sublist`) is not supported.
