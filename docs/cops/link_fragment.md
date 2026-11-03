# Prose/LinkFragment

Inspired by markdownlint MD051; disabled by default.

Checks only destinations beginning with `#` in inline and resolved reference links. Fragments are HTML-entity decoded and percent decoded, without treating `+` as a space; matching is case sensitive. Images and destinations such as `other.md#heading`, `/page#heading`, or `https://example.test/#heading` are intentionally not checked. No files or networks are fetched.

`Renderer` selects `github` (default), `gitlab`, or `kramdown`. GitHub-style slugs lowercase text, preserve Unicode letters/marks/numbers and underscores, remove punctuation, and replace spaces with hyphens. GitLab-style slugs additionally collapse consecutive hyphens. Kramdown-style slugs use ASCII letters/numbers/spaces/hyphens, discard a nonletter prefix, and fall back to `section`. Automatically generated duplicate slugs receive collision-aware `-1`, `-2`, etc. suffixes. These are explicit renderer-style algorithms, not compatibility guarantees for every renderer version or extension.

Heading text includes formatted text, code spans, entities, and image alt text. Explicit heading IDs and HTML `id` attributes (plus `a` element `name` attributes) are accepted. `AdditionalAnchors` lists case-sensitive IDs supplied by a site's renderer or template. `AllowEmptyFragment` defaults to `true`, allowing `#` as a page-top link independently of `Prose/EmptyLink`.

Only headings recognized by the shared Markdown parser are used, including its single-line setext headings; this rule does not impose a separate heading grammar.

Code blocks/spans, front matter, escaped syntax, HTML links, and comments/raw HTML regions do not supply Markdown links. The rule is report-only; it does not guess the intended heading or autocorrect fragments. It is not exact markdownlint equivalence.
