# Prose/FenceBlankLines

Opt-in counterpart of MD031. Parsed fenced code blocks require blank lines before and after adjacent content. File boundaries and a preceding front-matter closing line are accepted. Corrections insert container-aware blank lines, deduplicating boundaries shared by adjacent fences.

`ListItems` defaults to true; set it to false to skip fences anywhere inside list items. An opening fence on the list marker's own line never requires a blank before that line. This intentional difference from source-oriented markdownlint checks avoids detaching the fence from its list item. Indented code is ignored.
