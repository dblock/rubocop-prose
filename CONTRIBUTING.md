# Contributing

## Setup and validation

Use Ruby 3.2 or newer. Supported RuboCop versions are 1.72.1 and newer within 1.x.

```sh
bundle install
bundle exec rake
bundle exec rake build
```

The default Rake task runs RuboCop and RSpec. For a focused change, run its affected specs with `bundle exec rspec spec/path_to_spec.rb`; lint with `bundle exec rubocop`. `bundle exec rake build` verifies gem packaging. `RUBOCOP_VERSION=1.72.1 bundle install` selects the minimum supported version for compatibility checks.

CI runs separate lint and test workflows on every pull request and pushes to `main`. Tests cover minimum/current Ruby and RuboCop combinations, gem building, and optional Markdown source-mapping interoperability.

To include interoperability tests locally, set `RUBOCOP_MD_PATH` to the checkout used by the dedicated CI job, then run `bundle exec rspec spec/markdown_integration_spec.rb`. That checkout must expose the original-source API described in [DESIGN.md](DESIGN.md#preprocessor-interoperability). Without it, interoperability examples are skipped; standalone examples still run. Keep the functional dependency loading and checkout settings intact.

## Tests

Keep focused cop tests in `spec/<name>_spec.rb`. Cover offenses, exclusions, original Unicode locations, safe corrections, and ambiguous cases that must remain report-only. Shared document parsing is covered by `spec/document_spec.rb` and `spec/front_matter_spec.rb`.

Exercise the real CLI when changing plugin loading, stdin, suppression directives, or cross-cop corrections. Test both CLI-option and YAML plugin loading. Interoperability coverage must include both preprocessor loading orders, simultaneous prose/Ruby corrections, repeated runs, and stdin.

### Integration fixtures

CLI integration scenarios are file/data-driven under `spec/fixtures`. Each scenario is a directory containing `input.md`, `.rubocop.yml`, and `case.yml`. Autocorrectable scenarios also provide `expected.md`; without it, the input must remain byte-for-byte unchanged.

`spec/fixtures/integration/` contains standalone prose scenarios run by `spec/integration_spec.rb`. `spec/fixtures/markdown_integration/` contains preprocessor interoperability scenarios run by `spec/markdown_integration_spec.rb`. Directory placement selects the suite; no format or preprocessor flag is needed.

`case.yml` declares expected offense counts by cop under `offenses` and post-correction counts under `remaining_offenses`. All expectations are explicit, including empty maps for clean results. Add a scenario directory to the appropriate suite to add coverage without changing the runner.

The shared runner copies each directory to an isolated temporary workspace and runs the real RuboCop CLI from there so correction cannot modify repository files. It checks reporting, safe autocorrection, a repeated run, and stdin, with both CLI-option and configuration-file plugin loading. Assert unchanged input during reporting, exact corrected bytes, stable repeated runs, and unchanged on-disk files during stdin reporting. The interoperability suite also runs with both plugin require orders when `RUBOCOP_MD_PATH` is set; only that suite is skipped when the preprocessor is unavailable.

The composed-correction fixture intentionally includes trailing spaces and extra final blank lines. Its targeted Git whitespace attributes preserve those regression inputs.

Run `bundle exec rspec spec/integration_spec.rb spec/markdown_integration_spec.rb`. Set `RUBOCOP_MD_PATH` as described above to include interoperability scenarios.

## Adding a cop

Add the implementation under `lib/rubocop/cop/prose`, subclassing `RuboCop::Cop::Prose::Base`. Put defaults in `config/cops/<name>.yml` with `Enabled: false`, supported options, autocorrection safety, and applicable file patterns. The loader discovers cop implementations and merges configuration files automatically.

Add focused specs, a user-facing `docs/cops/<name>.md` with good/bad examples, and a linked entry with a one-line summary in [the README catalog](README.md#cop-catalog). Document behavior and limitations using the native cop name, without external rule IDs or plugin comparisons. Put implementation rationale in [DESIGN.md](DESIGN.md), not in the user guide. Validate default configuration and packaging when adding files.

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
