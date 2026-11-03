# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new(:rubocop)
task default: %i[rubocop spec]

desc 'Benchmark Markdown and text document analysis, linting, and single-pass autocorrection'
task :benchmark do
  ruby File.expand_path('benchmark/prose.rb', __dir__)
end
