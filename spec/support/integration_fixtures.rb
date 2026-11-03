# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'rbconfig'
require 'yaml'

module IntegrationFixtures
  ROOT = File.expand_path('../fixtures', __dir__)
  LIB = File.expand_path('../../lib', __dir__)

  def self.cases(directory)
    Dir.glob(File.join(ROOT, directory, '*', 'case.yml')).map do |path|
      [File.dirname(path), YAML.safe_load_file(path)]
    end
  end

  def run_fixture(fixture, data, loading, order)
    Dir.mktmpdir('rubocop-prose-fixture') do |directory|
      FileUtils.cp_r(File.join(fixture, '.'), directory)
      file = File.join(directory, 'example.md')
      source = File.binread(File.join(directory, 'input.md'))
      FileUtils.cp(File.join(directory, 'input.md'), file)
      configuration = File.join(directory, '.rubocop.yml')
      config = YAML.safe_load_file(configuration)
      if loading == 'options'
        config.delete('plugins')
        File.write(configuration, config.to_yaml)
      end
      only = config.select { |name, options| name.include?('/') && options.fetch('Enabled', false) }.keys
      raise ArgumentError, "No enabled cops in #{configuration}" if only.empty?

      command = fixture_command(configuration, only, loading, order)
      assert_fixture_report(command + ['example.md'], directory, data.fetch('offenses'))
      expect(File.binread(file)).to eq(source)

      expected_path = File.join(fixture, 'expected.md')
      expected = File.file?(expected_path) ? File.binread(expected_path) : source
      assert_fixture_report(command + ['-a', 'example.md'], directory, data.fetch('remaining_offenses'),
                            corrected: true)
      expect(File.binread(file)).to eq(expected)
      assert_fixture_report(command + ['example.md'], directory, data.fetch('remaining_offenses'))
      expect(File.binread(file)).to eq(expected)
      assert_fixture_report(command + ['--stdin', 'example.md'], directory, data.fetch('offenses'),
                            stdin_data: source)
      expect(File.binread(file)).to eq(expected)
    end
  end

  def fixture_command(configuration, only, loading, order)
    command = [RbConfig.ruby, "-I#{LIB}", '-rrubocop']
    if order
      markdown_path = ENV.fetch('RUBOCOP_MD_PATH')
      command << "-I#{File.join(File.expand_path(markdown_path), 'lib')}"
      requires = order == 'prose_first' ? %w[rubocop-prose rubocop-md] : %w[rubocop-md rubocop-prose]
      command.concat(requires.map { |name| "-r#{name}" })
    end
    command.push('-S', 'rubocop', '--config', configuration, '--cache', 'false', '--format', 'json',
                 '--only', only.join(','))
    command.push('--plugin', 'rubocop-prose') if loading == 'options'
    command
  end

  def assert_fixture_report(command, directory, expected, corrected: false, **)
    stdout, stderr, status = Open3.capture3(*command, chdir: directory, **)
    expect(status.exitstatus).to eq(expected.empty? ? 0 : 1), "#{command.join(' ')}\n#{stdout}\n#{stderr}"
    report = JSON.parse(stdout)
    offenses = report.fetch('files').flat_map { |file| file.fetch('offenses') }
    offenses = offenses.reject { |offense| offense.fetch('corrected') } if corrected
    expect(offenses.map { |offense| offense.fetch('cop_name') }.tally).to eq(expected)
    expect(report.fetch('summary').fetch('offense_count')).to eq(offenses.length) unless corrected
  end
end

RSpec.shared_examples 'a prose CLI fixture' do |fixture, data, order = nil|
  %w[options config].each do |loading|
    it "uses #{loading} plugin loading for reporting, correction, repeated runs, and stdin" do
      run_fixture(fixture, data, loading, order)
    end
  end
end
