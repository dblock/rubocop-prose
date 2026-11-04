# Contributing

## Setup and validation

Use Ruby 3.2 or newer. Supported RuboCop versions are 1.72.1 and newer within 1.x.

```sh
bundle install
bundle exec rake
bundle exec rake build
```

The default Rake task runs RuboCop and RSpec. For focused changes, run the affected specs with `bundle exec rspec spec/path_to_spec.rb` and lint with `bundle exec rubocop`. To test the minimum supported RuboCop version, use `RUBOCOP_VERSION=1.72.1 bundle install`.

CI runs lint, tests, and gem packaging on pull requests. The test matrix covers Ruby 3.2 and 4.0 with RuboCop `~> 1.72`; a separate job tests optional Markdown-preprocessor interoperability.

The project lint configuration loads this checkout's plugin alongside rubocop-rspec and rubocop-rake. Intentionally invalid integration fixtures are excluded. Cop specs use a flat `spec/<cop>_spec.rb` layout; focused assertions for diagnostics and corrections belong together.

### Benchmarks

Run `bundle exec rake benchmark`; set `ITERATIONS` and `SECTIONS` to override sample counts and corpus sizes, for example `ITERATIONS=5 SECTIONS=10,50,100 bundle exec rake benchmark`.

The benchmark compares document analysis, cop investigation, and in-memory autocorrection on Markdown and text corpora. Each operation constructs a fresh document; compare results only across revisions using the same Ruby, RuboCop, and corpus settings. Timings are machine-dependent, not CI thresholds.

## Tests

Keep focused cop tests in `spec/<name>_spec.rb`. Cover offenses, exclusions, Unicode source locations, safe corrections, and ambiguous rewrites that must remain report-only. Document adapters and file selection have dedicated specs; format-specific cops must not investigate the other format, even when explicitly selected.

Exercise the real CLI when changing plugin loading, stdin, suppression directives, or cross-cop corrections. Test both CLI-option and YAML plugin loading. Interoperability changes also need both preprocessor loading orders, simultaneous prose/Ruby corrections, repeated runs, and stdin.

### Integration fixtures

CLI scenarios live under `spec/fixtures/{prose,markdown,text,markdown_interoperability}/`; each suite runs from the matching directory under `spec/integration/`. A scenario contains an `input` document and `case.yml`; autocorrectable cases also include an `expected` document with the same extension. The case file declares expected offense counts under `offenses` and post-correction counts under `remaining_offenses`, including empty maps for clean results.

Fixtures with explicit `Enabled: true` cop entries run with `--only`; others exercise configured defaults. The shared runner checks explicit files, discovery, reporting, correction, repeated autocorrection and reporting, and stdin while keeping repository files unchanged. Put whitespace-sensitive fixtures under the existing Git whitespace attributes.

Mixed default-cop release-gate scenarios live under `spec/fixtures/markdown_stability/`. Their focused integration spec checks independently declared expected output and GFM content trees after every correction, allowing only soft-wrap, blank-padding, delimiter-style, and tight-list normalizations. It bounds convergence, rejects oscillation, and checks another byte-identical run after reaching a fixed point; the two scenarios cover YAML and CLI plugin loading without repeating the shared runner's full matrix.

Run `bundle exec rspec spec/integration`. To include the optional preprocessor suite, set `RUBOCOP_MD_PATH` to its checkout and run `bundle exec rspec spec/integration/markdown_interoperability_spec.rb`. Interoperability requires the original-buffer mapping API described in [DESIGN.md](DESIGN.md#preprocessor-interoperability); without it, only that suite is skipped.

## Adding a cop

Add implementations under `lib/rubocop/cop/prose`, `lib/rubocop/cop/markdown`, or `lib/rubocop/cop/text`, inheriting from the corresponding department `Base`. Add a per-cop YAML file under `config/cops/<department>/` with an explicit `Enabled` value, supported options, correction policy, and applicable file patterns. The loader discovers implementations and merges their configuration files.

Add focused specs, a guide under `docs/cops/<department>/` with complete default configuration and meaningful bad/good examples, and a linked one-line entry in the [README cops catalog](README.md#cops). Introduce example-specific settings with “For this configuration:” followed by a YAML block. Keep user-visible behavior and meaningful limits in the guide, implementation rationale in [DESIGN.md](DESIGN.md), and shared exclusions in the README. Use the native cop name; do not add numeric aliases or comparisons with other plugins.

Validate defaults, packaging, and the affected tests. Enable broadly applicable cleanup by default; keep project-specific, editorial, and renderer-dependent policies opt-in. Preserve functional dependency loading and compatibility CI settings.

## Pull requests

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
