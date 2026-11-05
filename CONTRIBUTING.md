# Contributing

## Setup and Validation

Use Ruby 3.2 or newer. Supported RuboCop versions are 1.72.1 and newer within 1.x.

```sh
bundle install
bundle exec rake
bundle exec rake build
```

The default Rake task runs RuboCop and the full test suite. For focused changes, use `bundle exec rspec spec/path_to_spec.rb` and `bundle exec rubocop`. Run unit or standalone integration tests separately with `bundle exec rake spec:unit` or `bundle exec rake spec:integration`. To install the minimum supported RuboCop, use `RUBOCOP_VERSION=1.72.1 bundle install`.

CI covers Ruby 3.2 and 4.0, gem packaging, and optional Markdown-preprocessor interoperability. See the [workflows](.github/workflows) for suite selection and dependency versions.

Run `COVERAGE=true bundle exec rake spec` to generate an HTML report in `coverage/` and `coverage/.resultset.json` for Coveralls. CI combines the Ruby 4.0 unit and standalone integration reports on [Coveralls](https://coveralls.io/github/dblock/rubocop-prose); subprocess smoke tests and optional interoperability are not instrumented.

The lint configuration loads this checkout's plugin alongside `rubocop-rspec` and `rubocop-rake`; intentionally invalid fixtures are excluded.

The repository also enables applicable opt-in prose cops for self-linting without changing their distributed defaults. `Markdown/HeadingStructure` stays disabled because documents do not share an exact outline. `Markdown/StructuralLineLength` limits headings to 120 columns, not code samples or tables. Raw HTML is limited to images with `src`, `alt`, and `width` attributes for the README artwork; the README is exempt from `Markdown/FirstHeading` to preserve its leading logo.

### Benchmarks

Run `bundle exec rake benchmark`; set `ITERATIONS` and `SECTIONS` to override sample counts and corpus sizes, for example `ITERATIONS=5 SECTIONS=10,50,100 bundle exec rake benchmark`.

The benchmark compares document analysis, cop investigation, and in-memory autocorrection on Markdown and text corpora. Each operation constructs a fresh document; compare results only across revisions using the same Ruby, RuboCop, and corpus settings. Timings are machine-dependent, not CI thresholds.

## Tests

Keep focused cop tests in `spec/<name>_spec.rb`. Cover offenses, exclusions, Unicode source locations, safe corrections, and ambiguous rewrites that must remain report-only. Document adapters and file selection have dedicated specs; format-specific cops must not investigate the other format, even when explicitly selected.

Exercise the real CLI when changing plugin loading, stdin, suppression directives, or cross-cop corrections. Test both CLI-option and YAML plugin loading. Interoperability changes also need both preprocessor loading orders, simultaneous prose/Ruby corrections, repeated runs, and stdin.

### Integration Fixtures

Scenarios live under `spec/fixtures/{prose,markdown,text,markdown_interoperability}/`, with specs in `spec/integration/` and `spec/interoperability/`. Each contains an `input` document, a `case.yml` declaring `offenses` and `remaining_offenses` counts (empty maps for clean results), and an `expected` document when correction changes the input.

Content fixtures call `RuboCop::CLI` in-process with fresh configuration state, checking explicit files, discovery, corrections, repeated runs, and stdin with both plugin-loading configurations. Fixtures with explicit `Enabled: true` cop entries run with `--only`; others exercise configured defaults. Mark whitespace-sensitive fixtures using the existing Git attributes.

Set `unsafe_autocorrect: true` in `case.yml` for fixtures that require `-A` instead of safe autocorrection.

Fresh-process smoke tests in `spec/integration/cli_spec.rb` check YAML and CLI-option plugin boot for Markdown and text, standard and custom-extension discovery, stdin without disk mutation, and stable corrections. Interoperability keeps a combined Ruby/Markdown scenario across both loading orders and plugin-loading mechanisms; edge cases check reporting, correction, and stability under both loading orders using YAML plugin loading.

Mixed default-cop scenarios in `spec/fixtures/markdown_stability/` check content and document structure after every correction, convergence without cycles, and byte-identical output after stabilization.

For optional interoperability, set `RUBOCOP_MD_PATH` to a checkout supporting the [original-buffer mapping API](DESIGN.md#preprocessor-interoperability) and run `bundle exec rake spec:interoperability`. Without that variable, the suite is skipped. Its separate CI workflow runs only on Ruby 4.0; update the `rubocop-md` ref when the required API is released.

## Adding a Cop

Add implementations under `lib/rubocop/cop/prose`, `lib/rubocop/cop/markdown`, or `lib/rubocop/cop/text`, inheriting from the corresponding department `Base`. Add a per-cop YAML file under `config/cops/<department>/` with an explicit `Enabled` value, supported options, correction policy, and applicable file patterns. The loader discovers implementations and merges their configuration files.

Add focused specs, a guide under `docs/cops/<department>/` with complete default configuration and meaningful bad/good examples, and a linked one-line entry in the [README cops catalog](README.md#cops). Introduce example-specific settings with “For this configuration:” followed by a YAML block. Keep user-visible behavior and meaningful limits in the guide, implementation rationale in [DESIGN.md](DESIGN.md), and shared exclusions in the README. Use the native cop name; do not add numeric aliases or comparisons with other plugins.

Validate defaults, packaging, and the affected tests. Enable broadly applicable cleanup by default; keep project-specific, editorial, and renderer-dependent policies opt-in. Preserve functional dependency loading and compatibility CI settings.

## Pull Requests

See [RELEASING.md](RELEASING.md) for the maintainer release procedure.

Keep each pull request focused, with one coherent commit, and use squash merges. Include behavior and configuration documentation. Preserve unrelated worktree changes.

Add a linked unreleased changelog entry only for a notable user-facing change, using the actual pull-request number. Do not add entries for documentation, tooling, refactoring, or unreleased functionality; update an existing feature entry when appropriate.

```markdown
- [#123](https://github.com/dblock/rubocop-prose/pull/123): Describe the change - [@dblock](https://github.com/dblock).
```

Keep each Markdown paragraph on one source line. Do not duplicate developer instructions in the README, cop guides, or asset notes.

## Artwork

Edit `assets/logo.svg`, leaving the upstream `assets/rubocop-logo.svg` unchanged and retaining the notice in `assets/RUBOCOP-LICENSE`. The composition and attribution are documented in [DESIGN.md](DESIGN.md#artwork).

Inspect the animation and reduced-motion rendering in a browser. Keep the PNG a static, fully unrolled fallback; the README uses the GIF because GitHub does not reliably preserve SVG animation. When changing the animation, regenerate the GIF from a full six-second SVG cycle at 15 frames per second, with the fully unrolled first frame and infinite looping.

With `rsvg-convert` installed, regenerate the 512px PNG from the repository root:

```sh
rsvg-convert assets/logo.svg -o assets/logo.png
```

Check the full-size PNG and 160px README rendering for clipping, legibility, scroll orientation, and separation from the helmet. Keep the opaque white background and package all artwork sources, rendered images, and the upstream notice together.
