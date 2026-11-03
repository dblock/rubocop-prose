# Prose/BlockquoteSpacing

Opt-in counterpart of MD027. Multiple spaces or tabs after a blockquote marker are replaced with one space. Nested quote markers are checked separately. Missing spaces are not reported.

Code and front matter are excluded. Indentation after the innermost quote marker within a parsed list is deliberately preserved, as are empty quote lines; those spaces can carry list structure. Unlike markdownlint, this rule does not attempt to distinguish superfluous spacing from required list indentation inside list items.
