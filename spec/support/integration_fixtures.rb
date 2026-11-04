# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'rbconfig'
require 'stringio'
require 'yaml'

module IntegrationFixtures
  ROOT = File.expand_path('../fixtures', __dir__)
  LIB = File.expand_path('../../lib', __dir__)

  def self.cases(directory)
    Dir.glob(File.join(ROOT, directory, '*', 'case.yml')).map do |path|
      [File.dirname(path), YAML.safe_load_file(path)]
    end
  end

  def run_fixture(fixture, data, loading, order, in_process: false, comprehensive: true)
    fixture_config = RuboCop::Config.new(YAML.safe_load_file(File.join(fixture, '.rubocop.yml')))
    inputs = Dir.glob(File.join(fixture, 'input.*')).select do |path|
      RuboCop::Prose::Document.file?(path, fixture_config)
    end
    raise ArgumentError, "Expected one input document in #{fixture}" unless inputs.one?

    input = inputs.first
    extension = File.extname(input)
    filename = "example#{extension}"
    expected_path = File.join(fixture, "expected#{extension}")
    Dir.mktmpdir('rubocop-prose-fixture') do |directory|
      FileUtils.cp_r(File.join(fixture, '.'), directory)
      file = File.join(directory, filename)
      source = File.binread(input)
      FileUtils.mv(File.join(directory, File.basename(input)), file)
      FileUtils.rm(File.join(directory, File.basename(expected_path))) if File.file?(expected_path)
      configuration = File.join(directory, '.rubocop.yml')
      config = YAML.safe_load_file(configuration)
      if loading == 'options'
        config.delete('plugins')
        File.write(configuration, config.to_yaml)
      end
      only = config.select { |name, options| name.include?('/') && options.fetch('Enabled', false) }.keys
      command = fixture_command(configuration, only, loading, order, in_process: in_process)
      assert_fixture_report(command + [filename], directory, data.fetch('offenses'), in_process: in_process)
      assert_fixture_report(command, directory, data.fetch('offenses'), in_process: in_process) if comprehensive
      expect(File.binread(file)).to eq(source)

      expected = File.file?(expected_path) ? File.binread(expected_path) : source
      assert_fixture_report(command + ['-a', filename], directory, data.fetch('remaining_offenses'),
                            corrected: true, in_process: in_process)
      expect(File.binread(file)).to eq(expected)
      assert_fixture_report(command + ['-a', filename], directory, data.fetch('remaining_offenses'),
                            corrected: true, in_process: in_process)
      expect(File.binread(file)).to eq(expected)
      next unless comprehensive

      assert_fixture_report(command + [filename], directory, data.fetch('remaining_offenses'), in_process: in_process)
      expect(File.binread(file)).to eq(expected)
      assert_fixture_report(command + ['--stdin', filename], directory, data.fetch('offenses'),
                            stdin_data: source, in_process: in_process)
      expect(File.binread(file)).to eq(expected)
    end
  end

  def fixture_command(configuration, only, loading, order, in_process: false)
    raise ArgumentError, 'Preprocessor loading order requires a fresh process' if order && in_process

    command = in_process ? [] : [RbConfig.ruby, "-I#{LIB}", '-rrubocop']
    if order
      markdown_path = ENV.fetch('RUBOCOP_MD_PATH')
      command << "-I#{File.join(File.expand_path(markdown_path), 'lib')}"
      requires = order == 'prose_first' ? %w[rubocop-prose rubocop-md] : %w[rubocop-md rubocop-prose]
      command.concat(requires.map { |name| "-r#{name}" })
    end
    command.push('-S', 'rubocop') unless in_process
    command.push('--config', configuration, '--cache', 'false', '--format', 'json')
    command.push('--only', only.join(',')) unless only.empty?
    command.push('--plugin', 'rubocop-prose') if loading == 'options'
    command
  end

  def run_fixture_cli(arguments, directory, stdin_data: '')
    previous_streams = [$stdout, $stderr, $stdin]
    previous_defaults = RuboCop::ConfigLoader.default_configuration
    previous_root = RuboCop::ConfigFinder.project_root
    $stdout = StringIO.new
    $stderr = StringIO.new
    $stdin = StringIO.new(stdin_data)
    RuboCop::ConfigLoader.clear_options
    RuboCop::ConfigLoader.default_configuration = nil
    RuboCop::ConfigFinder.project_root = nil
    status = Dir.chdir(directory) do
      RuboCop::PathUtil.reset_pwd if RuboCop::PathUtil.respond_to?(:reset_pwd)
      RuboCop::CLI.new.run(arguments.dup)
    end
    [$stdout.string, $stderr.string, status]
  ensure
    $stdout, $stderr, $stdin = previous_streams
    RuboCop::ConfigLoader.clear_options
    RuboCop::ConfigLoader.default_configuration = previous_defaults
    RuboCop::ConfigFinder.project_root = previous_root
    RuboCop::PathUtil.reset_pwd if RuboCop::PathUtil.respond_to?(:reset_pwd)
  end

  def assert_fixture_report(command, directory, expected, corrected: false, in_process: false, **)
    stdout, stderr, status = if in_process
                               run_fixture_cli(command, directory, **)
                             else
                               output, errors, result = Open3.capture3(*command, chdir: directory, **)
                               [output, errors, result.exitstatus]
                             end
    expect(status).to eq(expected.empty? ? 0 : 1), "#{command.join(' ')}\n#{stdout}\n#{stderr}"
    report = JSON.parse(stdout)
    offenses = report.fetch('files').flat_map { |file| file.fetch('offenses') }
    offenses = offenses.reject { |offense| offense.fetch('corrected') } if corrected
    expect(offenses.map { |offense| offense.fetch('cop_name') }.tally).to eq(expected)
    expect(report.fetch('summary').fetch('offense_count')).to eq(offenses.length) unless corrected
  end
end

RSpec.shared_examples 'a prose content fixture' do |fixture, data|
  %w[options config].each do |loading|
    it "checks #{loading} configuration, corrections, repeated runs, and stdin in process" do
      run_fixture(fixture, data, loading, nil, in_process: true)
    end
  end
end

RSpec.shared_examples 'a prose CLI fixture' do |fixture, data, order = nil|
  %w[options config].each do |loading|
    it "uses #{loading} plugin loading for reporting, correction, repeated runs, and stdin" do
      run_fixture(fixture, data, loading, order)
    end
  end
end
