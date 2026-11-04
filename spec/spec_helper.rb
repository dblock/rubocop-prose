# frozen_string_literal: true

if ENV['COVERAGE'] == 'true'
  require 'simplecov'

  SimpleCov.start do
    track_files 'lib/**/*.rb'
    add_filter '/spec/'
  end
end

require 'rubocop-prose'
require 'tmpdir'
require 'open3'
require_relative 'support/integration_fixtures'

module ProseHelpers
  def investigate(cop_class, source, options = {}, path: 'example.md', settings: {}, **cop_options)
    options = options.merge(cop_options.transform_keys(&:to_s))
    defaults = RuboCop::Prose.default_configuration
    defaults.merge!(settings)
    cop_classes = Array(cop_class)
    cop_classes.each do |klass|
      name = klass.cop_name
      defaults[name] = defaults.fetch(name, {}).merge(options).merge('Enabled' => true)
    end
    configuration = RuboCop::ConfigLoader.merge_with_default(
      RuboCop::Config.new(defaults), File.expand_path('../.rubocop.yml', __dir__)
    )
    processed = RuboCop::ProcessedSource.new(source, 3.2, path, prose_configuration: configuration)
    processed.config = configuration if processed.respond_to?(:config=)
    processed.registry = RuboCop::Cop::Registry.new(cop_classes) if processed.respond_to?(:registry=)
    team = RuboCop::Cop::Team.mobilize(cop_classes, configuration, raise_error: true, autocorrect: true)
    report = team.investigate(processed)
    corrector = report.correctors.compact.first
    [report.offenses.reject(&:disabled?), corrector ? corrector.rewrite : source]
  end

  def offenses(cop_class, source, options = {}, **keywords)
    investigate(cop_class, source, options, **keywords).first
  end

  def corrected(cop_class, source, options = {}, **keywords)
    investigate(cop_class, source, options, **keywords).last
  end
end

RSpec.configure do |config|
  config.include ProseHelpers
  config.include IntegrationFixtures
  config.disable_monkey_patching!
  config.expect_with(:rspec) { |expectations| expectations.syntax = :expect }
end
