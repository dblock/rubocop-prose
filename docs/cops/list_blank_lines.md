# Prose/ListBlankLines

Opt-in counterpart of MD032. Parsed lists need a blank line before and after adjacent content. File boundaries count as blank boundaries; a front-matter closing line is also accepted before a list. Corrections insert blank lines and retain quote prefixes.

Nested lists do not require separation from their parent items. Unlike markdownlint's line-oriented heuristics, lazy continuation text belonging to a list item is not treated as content after the list. Code and marker-shaped non-list text are ignored.
