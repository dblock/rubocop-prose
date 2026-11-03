# Integration fixtures

Each scenario is a directory containing `input.md`, `.rubocop.yml`, and `case.yml`. Autocorrectable scenarios also provide `expected.md`; without it, the input must remain byte-for-byte unchanged.

`integration/` contains standalone prose scenarios run by `spec/integration_spec.rb`. `markdown_integration/` contains preprocessor interoperability scenarios run by `spec/markdown_integration_spec.rb`. Directory placement selects the suite; no format or preprocessor flag is needed.

`case.yml` declares expected offense counts by cop before correction and remaining offense counts afterward. All expectations are explicit, including empty maps for clean results. Add a scenario directory to the appropriate suite to add coverage without changing the runner.

The shared runner copies each directory to a temporary workspace and runs the real RuboCop CLI from there. It checks reporting, safe autocorrection, a repeated run, and stdin, with both CLI-option and configuration-file plugin loading. The interoperability suite also runs with both plugin require orders when `RUBOCOP_MD_PATH` is set; only that suite is skipped when the preprocessor is unavailable.

The composed-correction fixture intentionally includes trailing spaces and extra final blank lines. Its targeted Git whitespace attributes preserve those regression inputs.

Run `bundle exec rspec spec/integration_spec.rb spec/markdown_integration_spec.rb`. Set `RUBOCOP_MD_PATH` to a Markdown preprocessor checkout exposing its original-buffer API to include interoperability scenarios.
