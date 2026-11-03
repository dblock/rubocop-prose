# Prose/CodeBlockStyle

Opt-in counterpart of MD046. `EnforcedStyle` is `fenced`, `indented`, or `consistent` (default). Consistent mode adopts the first parsed code block's style across the document, including nested containers.

Corrections are intentionally conservative. Only standalone root-level blocks with blank boundaries are converted. Fences with language or other metadata, nested list/quote blocks, empty fenced bodies, bodies with leading or trailing blank lines, and source mappings that cannot be reproduced exactly are report-only. Conversion to indentation is also report-only beside any code block separated only by whitespace, avoiding merges during simultaneous corrections. Converting indentation to fences requires literal four-space indentation and uses a backtick fence longer than any content backtick run.

Unlike markdownlint, conversion is not attempted when it could discard metadata or change container structure. Front matter and code-looking text not parsed as code blocks are excluded.
