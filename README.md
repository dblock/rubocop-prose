# rubocop-prose

<img src="assets/logo.png" alt="The RuboCop helmet logo with a parchment scroll alongside it." width="160">

Markdown prose, structure, and style checks for RuboCop. Ruby snippets belong to [rubocop-md](https://github.com/rubocop/rubocop-md); spelling belongs to [rubocop-spellcheck](https://github.com/dblock/rubocop-spellcheck).

The initial implementation was developed as a stack of focused feature pull requests.

## Installation

The initial release is in development. Add this repository to your Gemfile:

```ruby
gem 'rubocop-prose', github: 'dblock/rubocop-prose'
```

Load it using RuboCop's plugin interface:

```yaml
plugins:
  - rubocop-prose
```

Document rules are opt-in. Enable individual `Prose/*` cops in `.rubocop.yml`; the [cop catalog](docs/cops.md) links their configuration, examples, and supported scope. Supported Markdown extensions match rubocop-md. Ruby files are unaffected, and no JavaScript runtime or external linter is needed.

## Integration

The plugin parses Markdown rather than Ruby, preserving original Unicode locations. When rubocop-md exposes its original Markdown buffer and range mapping, prose and Ruby corrections share that mapping without replacing its processed Ruby buffer. Hidden directives use native RuboCop syntax, for example `<!-- # rubocop:disable Prose/MaxLength -->`.

Interoperability requires the original-buffer API proposed in [rubocop-md#57](https://github.com/rubocop/rubocop-md/pull/57); older releases without that API are not supported. CI checks both plugin load orders, simultaneous Ruby and prose corrections, repeated runs, and stdin against that proposal.

The foundation follows rubocop-spellcheck's evolution: a standard `lint_roller` plugin, source-preserving document adapter, separate lint/test workflows, and coverage of the minimum supported RuboCop alongside current versions. Prose formatting and document-rule work originated in rubocop-md proposals #50, #53, and #54 and belongs here rather than in a Ruby-snippet linter.

## Development

Run `bundle install`, then `bundle exec rake` for lint and tests. Ruby 3.2 or newer and RuboCop 1.72.1 or newer within 1.x are supported. CI runs on every pull request and pushes to `main`.

Set `RUBOCOP_MD_PATH` to an original-buffer-enabled rubocop-md checkout to include interoperability checks locally. The source adapter and rule set do not require rubocop-md for standalone Markdown linting.

CLI integration scenarios are file/data-driven under [`spec/fixtures`](spec/fixtures/README.md). Each directory supplies Markdown input, cop configuration, expected diagnostics, and optional corrected output; the shared runner uses isolated temporary workspaces.
