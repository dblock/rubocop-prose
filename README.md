# rubocop-prose

Markdown prose, structure, and style checks for RuboCop. Ruby snippets belong to [rubocop-md](https://github.com/rubocop/rubocop-md); spelling belongs to [rubocop-spellcheck](https://github.com/dblock/rubocop-spellcheck).

Development is organized as a stack of focused feature pull requests.

## Installation

Add `rubocop-prose` to your Gemfile and load it using RuboCop's plugin interface:

```yaml
plugins:
  - rubocop-prose
```

Document rules are opt-in. Enable individual `Prose/*` cops in `.rubocop.yml`; their configuration and examples live in `docs/cops/`. Supported Markdown extensions match rubocop-md. Ruby files are unaffected, and no JavaScript runtime or external linter is needed.

## Integration

The plugin parses Markdown rather than Ruby, preserving original Unicode locations. When rubocop-md exposes its original Markdown buffer and range mapping, prose and Ruby corrections share that mapping without replacing its processed Ruby buffer. Hidden directives use native RuboCop syntax, for example `<!-- # rubocop:disable Prose/MaxLength -->`.

The foundation follows rubocop-spellcheck's evolution: a standard `lint_roller` plugin, source-preserving document adapter, separate lint/test workflows, and coverage of the minimum supported RuboCop alongside current versions. Prose formatting and document-rule work originated in rubocop-md proposals #50, #53, and #54 and belongs here rather than in a Ruby-snippet linter.

## Development

Run `bundle install`, then `bundle exec rake` for lint and tests. Ruby 3.2 or newer and RuboCop 1.72.1 or newer within 1.x are supported. CI runs on every pull request, including each feature-stack snapshot, and pushes to `master`.
