# Prose/FenceLanguage

Opt-in counterpart of MD040. Every parsed fenced code block must specify a language. `AllowedLanguages` defaults to an empty list, accepting any nonempty language; otherwise only listed, case-sensitive names are accepted. Nested list and quote fences are included; indented code and front matter are ignored.

This rule is report-only because the language cannot safely be inferred. Unlike markdownlint, language aliases are not normalized and a separate language-only information-string mode is not provided. Language metadata is read from the parser, not guessed from raw fence-looking text; only fence syntax recognized by the configured Markdown parser is checked.
