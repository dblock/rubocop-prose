# Contributor Instructions

Read [CONTRIBUTING.md](CONTRIBUTING.md) for setup, tests, and pull-request conventions. Read [DESIGN.md](DESIGN.md) before changing parsing, source mapping, or correction behavior.

Keep user guidance in the README and cop guides, contributor workflow in CONTRIBUTING, architecture and rationale in DESIGN, and this file focused on high-value agent guidance. Link to the authoritative documentation instead of duplicating it.

Migration documentation must identify the source released version, for example `Migrating From 0.1.0`, rather than using generic “Migration” or “earlier versions” wording. Put migration sections last in cop guides, after configuration and all good/bad examples. Keep them focused on required configuration changes and examples, without explaining validation machinery or restating unchanged settings. Do not describe unreleased schema iterations as migrations.

Verify each configuration migration once with a focused unit test of its RuboCop migration rule. Do not add integration tests for obsolete configurations; keep integration coverage focused on supported configuration and cop behavior.

Update DESIGN only for new architectural decisions or non-obvious invariants not already covered there. Do not add per-cop implementation summaries or repeat configuration behavior from cop guides; ordinary feature changes usually need no DESIGN update.

Preserve original source buffers and character-based locations, Markdown container prefixes and hard breaks, and atomic inline syntax. Plain text must remain literal; format-specific cops must not inspect the other format. Withhold corrections when a safe rewrite cannot be established.

Keep common cleanup enabled by default and project-specific, editorial, or renderer-dependent policies opt-in. Do not add an external preprocessor dependency. Preserve functional dependency loading and compatibility settings.

When adding a cop, follow the checklist in [CONTRIBUTING.md](CONTRIBUTING.md#adding-a-cop); document its user-visible behavior and meaningful limits without repeating shared exclusions.

Enable new cops in this repository's `.rubocop.yml` and include applicable self-linting changes in the feature PR so reviewers can see their effect. Keep the distributed default independent: editorial policies remain opt-in for users.

Do not edit historical changelog entries or add one for documentation, tooling, refactoring, or unreleased functionality. Keep `- Your contribution here.` at the end of the `(Next)` changelog change list without a blank line above it; remove it only when preparing that version for release. Preserve the vendored helmet SVG and its license; follow CONTRIBUTING for artwork changes.
