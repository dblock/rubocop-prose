# Contributing

## Setup and validation

Use Ruby 3.2 or newer. Supported RuboCop versions are 1.72.1 and newer within 1.x.

```sh
bundle install
bundle exec rake
bundle exec rake build
```

The default Rake task runs RuboCop and RSpec. For a focused change, run its affected specs with `bundle exec rspec spec/path_to_spec.rb`; lint with `bundle exec rubocop`. `bundle exec rake build` verifies gem packaging. `RUBOCOP_VERSION=1.72.1 bundle install` selects the minimum supported version for compatibility checks.

CI runs separate lint and test workflows on every pull request and pushes to `main`. Each row in the test workflow's `matrix.entry` lists one Ruby/RuboCop combination explicitly. Tests cover Ruby 3.2 and 4.0 with RuboCop `~> 1.72`, gem building, and optional Markdown source-mapping interoperability. Pull requests also run Danger checks for changelog entries.

The lint configuration loads this checkout's rubocop-prose plugin to check project prose alongside Ruby. Intentionally invalid integration fixtures are excluded from project linting.

To include interoperability tests locally, set `RUBOCOP_MD_PATH` to the checkout used by the dedicated CI job, then run `bundle exec rspec spec/integration/markdown_interoperability_spec.rb`. That checkout must expose the original-source API described in [DESIGN.md](DESIGN.md#preprocessor-interoperability). Without it, interoperability examples are skipped; standalone examples still run. Keep the functional dependency loading and checkout settings intact.

## Tests

Keep focused cop tests in `spec/<name>_spec.rb`. Cover offenses, exclusions, original Unicode locations, safe corrections, and ambiguous cases that must remain report-only. Document adapters are covered by `spec/document_spec.rb`, `spec/text_document_spec.rb`, and `spec/front_matter_spec.rb`. File-pattern validation, inherited per-file configuration, and discovery are covered by `spec/file_types_spec.rb`. Format-specific cops must not investigate the other format, even when explicitly selected.

Exercise the real CLI when changing plugin loading, stdin, suppression directives, or cross-cop corrections. Test both CLI-option and YAML plugin loading. Interoperability coverage must include both preprocessor loading orders, simultaneous prose/Ruby corrections, repeated runs, and stdin.

### Integration fixtures

CLI integration scenarios are file/data-driven under `spec/fixtures`. Each scenario contains one `input` document selected by its `.rubocop.yml`, plus `case.yml`. Autocorrectable scenarios also provide `expected` with the same extension as the input; without it, the input must remain byte-for-byte unchanged. Custom patterns and uppercase suffixes use the same runner.

Integration entry points live in `spec/integration/`. Their fixture subfolders are `spec/fixtures/prose/`, `spec/fixtures/markdown/`, `spec/fixtures/text/`, and `spec/fixtures/markdown_interoperability/`. Directory placement selects the suite, while the input extension selects the document adapter; no format or preprocessor flag is needed.

`case.yml` declares expected offense counts by cop under `offenses` and post-correction counts under `remaining_offenses`. All expectations are explicit, including empty maps for clean results. Add a scenario directory to the appropriate suite to add coverage without changing the runner.

Fixtures with explicit `Enabled: true` cop entries run with `--only` for those cops. Fixtures without such entries run the configured defaults without `--only`, covering normal plugin behavior.

The shared runner copies each directory to an isolated temporary workspace and runs the real RuboCop CLI from there so correction cannot modify repository files. It renames the input to an example document and removes the copied expectation document from discovery. It checks explicit-file reporting, automatic file discovery, safe autocorrection, a repeated run, and stdin, with both CLI-option and configuration-file plugin loading. Assert unchanged input during reporting, exact corrected bytes, stable repeated runs, and unchanged on-disk files during stdin reporting. The interoperability suite also runs with both plugin require orders when `RUBOCOP_MD_PATH` is set; only that suite is skipped when the preprocessor is unavailable.

Whitespace and default-policy fixtures intentionally include trailing spaces or extra blank lines. Targeted Git whitespace attributes preserve those regression inputs.

Run `bundle exec rspec spec/integration`. Set `RUBOCOP_MD_PATH` as described above to include interoperability scenarios.

## Adding a cop

Add the implementation under `lib/rubocop/cop/prose`, `lib/rubocop/cop/markdown`, or `lib/rubocop/cop/text`, subclassing that department's `Base`: `RuboCop::Cop::Prose::Base`, `RuboCop::Cop::Markdown::Base`, or `RuboCop::Cop::Text::Base`. Put defaults in `config/cops/<department>/<name>.yml` with an explicit `Enabled` value, supported options, autocorrection safety, and applicable file patterns. Enable broadly applicable cleanup by default; leave project-specific, editorial, and renderer-dependent policies opt-in. The loader loads the abstract bases before discovering cop implementations and merges configuration files automatically.

Add focused specs, a user-facing `docs/cops/<department>/<name>.md` with good/bad examples, and a linked entry with a one-line summary in [the README cops section](README.md#cops). Document behavior and limitations using the native cop name, without external rule IDs or plugin comparisons. Put implementation rationale in [DESIGN.md](DESIGN.md), not in the user guide. Validate default configuration and packaging when adding files.

Put complete default settings under `Configuration`, followed by one `Example` section with bad/good inputs. Show example-specific overrides there when needed. Link mentions of other cops to their documentation. Keep Markdown and text cop guides focused on their own format rather than explaining exclusions for the other format.

## Pull requests

Keep each feature in a focused pull request with one coherent commit; use squash merges. Include behavior/configuration documentation with the change. Preserve unrelated worktree changes.

Add an unreleased changelog entry using this format, with the actual pull-request number:

```markdown
- [#123](https://github.com/dblock/rubocop-prose/pull/123): Describe the change - [@dblock](https://github.com/dblock).
```

Keep each Markdown paragraph on one source line. Do not duplicate developer instructions in README, cop documentation, or asset notes.

## Artwork

Edit `assets/logo.svg`, leaving the adjacent `assets/rubocop-logo.svg` unchanged. Keep the upstream license notice in `assets/RUBOCOP-LICENSE`. The composition and licensing rationale are documented in [DESIGN.md](DESIGN.md#artwork).

With `rsvg-convert` installed, regenerate the committed image from the repository root:

```sh
rsvg-convert assets/logo.svg -o assets/logo.png
```

Check the 512px PNG and its 160px README rendering for clipping, legibility, vertical scroll orientation, and separation from the helmet. Keep the opaque white background and package the SVG, rendered PNG, upstream source, and license together.
