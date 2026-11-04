# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)
namespace :spec do
  RSpec::Core::RakeTask.new(:unit) do |task|
    task.exclude_pattern = 'spec/integration/**/*_spec.rb'
  end
  RSpec::Core::RakeTask.new(:integration) do |task|
    task.pattern = 'spec/integration/**/*_spec.rb'
  end
  namespace :integration do
    RSpec::Core::RakeTask.new(:markdown) do |task|
      task.pattern = 'spec/integration/markdown_spec.rb'
    end
    RSpec::Core::RakeTask.new(:prose_and_text) do |task|
      task.pattern = 'spec/integration/**/*_spec.rb'
      task.exclude_pattern = 'spec/integration/{markdown,markdown_interoperability}_spec.rb'
    end
    RSpec::Core::RakeTask.new(:interoperability) do |task|
      task.pattern = 'spec/integration/markdown_interoperability_spec.rb'
    end
  end
end
RuboCop::RakeTask.new(:rubocop)
task default: %i[rubocop spec]

desc 'Benchmark Markdown and text document analysis, linting, and single-pass autocorrection'
task :benchmark do
  ruby File.expand_path('benchmark/prose.rb', __dir__)
end
