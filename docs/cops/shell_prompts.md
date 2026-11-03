# Prose/ShellPrompts

Opt-in counterpart of MD014. In fenced blocks whose language is in `ShellLanguages` (default: `bash`, `console`, `ksh`, `sh`, `shell`, `zsh`), remove `$ ` from each command only when every nonblank line starts with that prompt. Blank lines are preserved. Corrections retain list and quote container prefixes.

Any output or unprompted continuation makes the entire block ineligible. If removing prompts could expose a closing fence inside the example, all offenses in that block are report-only. Unlike markdownlint, unlabeled and indented blocks are deliberately ignored, and shell languages are explicitly configurable and case-sensitive. Root prompts (`#`) and other prompt formats are not interpreted.
