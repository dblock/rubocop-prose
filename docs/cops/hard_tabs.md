# Prose/HardTabs

Opt-in MD010-style hard-tab diagnostics with original character columns. `CodeBlocks` defaults to `true`; set it to `false` to ignore code. `AllowedCodeLanguages` excludes named fenced languages case-insensitively, such as `make`.

This rule is report-only: a tab's intended width and meaning depend on context, and replacing tabs inside embedded strings or Makefiles is unsafe.
