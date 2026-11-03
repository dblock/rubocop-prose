# frozen_string_literal: true

require_relative 'lib/rubocop/prose/version'

Gem::Specification.new do |spec|
  spec.name = 'rubocop-prose'
  spec.version = RuboCop::Prose::VERSION
  spec.authors = ['Daniel (dB.) Doubrovkine']
  spec.email = ['dblock@dblock.org']
  spec.summary = 'Markdown prose, structure, and style checks for RuboCop.'
  spec.description = 'Parser-backed RuboCop cops for Markdown documents, with source-preserving corrections.'
  spec.homepage = 'https://github.com/dblock/rubocop-prose'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.2'
  spec.metadata = {
    'allowed_push_host' => 'https://rubygems.org',
    'source_code_uri' => spec.homepage,
    'changelog_uri' => "#{spec.homepage}/blob/main/CHANGELOG.md",
    'bug_tracker_uri' => "#{spec.homepage}/issues",
    'rubygems_mfa_required' => 'true',
    'default_lint_roller_plugin' => 'RuboCop::Prose::Plugin'
  }
  spec.files = Dir['lib/**/*.rb', 'config/**/*.yml', 'docs/**/*.md', 'assets/**/*'] +
               %w[README.md CHANGELOG.md CONTRIBUTING.md DESIGN.md AGENTS.md LICENSE.txt]
  spec.require_paths = ['lib']
  spec.add_dependency 'kramdown', '~> 2.5'
  spec.add_dependency 'kramdown-parser-gfm', '~> 1.1'
  spec.add_dependency 'lint_roller', '~> 1.1'
  spec.add_dependency 'rubocop', '~> 1.72', '>= 1.72.1'
end
