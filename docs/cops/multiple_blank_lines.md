# Prose/MultipleBlankLines

Opt-in MD012-style consecutive blank-line limits outside code blocks and ignored metadata. `Max` is a non-negative integer, default `1`. Excess blank lines are safely removed while retaining paragraph separation.

`Max: 0` is report-only: deleting all paragraph separators changes Markdown structure. Blank blockquote markers are handled by the dedicated blockquote rule rather than counted as empty lines here.
