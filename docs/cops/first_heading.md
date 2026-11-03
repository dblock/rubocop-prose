# Prose/FirstHeading

Related rule: MD041. Disabled by default.

Requires the first nonblank content line to begin a parsed heading at `Level` (default `1`). ATX and Setext headings qualify; leading prose, HTML and code do not. Empty and front-matter-only documents are accepted.

`FrontMatterTitle: true` (default) permits any document with a nonempty string at the top-level YAML key specified by `TitleKey` (default `title`); set it to `false` to always require a heading. Invalid or unsafe YAML, aliases and non-string titles do not qualify. Title keys are exact, not markdownlint regular expressions.

Parsed container headings count if they begin on the first content line. Report-only: adding or moving a title changes structure.
