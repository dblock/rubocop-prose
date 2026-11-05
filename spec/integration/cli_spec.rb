# frozen_string_literal: true

RSpec.describe 'Fresh-process CLI smoke tests' do
  %w[backslash spaces].each do |style|
    %w[config options].each do |loading|
      it "coordinates #{style} hard breaks and trailing whitespace with #{loading} plugin loading" do
        Dir.mktmpdir('cli-hard-break-styles-') do |directory|
          configuration = File.join(directory, '.rubocop.yml')
          config = {
            'Markdown/HardBreakStyle' => { 'Enabled' => true, 'Style' => style },
            'Markdown/TrailingWhitespace' => { 'Enabled' => true }
          }
          config['plugins'] = ['rubocop-prose'] if loading == 'config'
          File.write(configuration, config.to_yaml)
          source_marker, expected_marker = style == 'backslash' ? ['    ', '\\'] : ['\\', '  ']
          source = "> Café.#{source_marker}\n> Next.\n\nLast. \n"
          expected = "> Café.#{expected_marker}\n> Next.\n\nLast.\n"
          file = File.join(directory, 'example.md')
          File.write(file, source)
          command = fixture_command(configuration, config.keys.grep(%r{/}), loading, nil)
          assert_fixture_report(command + ['example.md'], directory,
                                { 'Markdown/HardBreakStyle' => 1, 'Markdown/TrailingWhitespace' => 1 })
          2.times do
            assert_fixture_report(command + ['-a', 'example.md'], directory, {}, corrected: true)
            expect(File.binread(file)).to eq(expected.b)
          end
        end
      end
    end
  end
  it 'applies default-enabled Text/HardTabs to plain text through both plugin loading mechanisms' do
    Dir.mktmpdir('cli-text-hard-tabs-') do |directory|
      configuration = File.join(directory, '.rubocop.yml')
      File.write(File.join(directory, 'example.txt'), "A\tparagraph.\n")
      %w[config options].each do |loading|
        config = {}
        config['plugins'] = ['rubocop-prose'] if loading == 'config'
        File.write(configuration, config.to_yaml)
        command = fixture_command(configuration, [], loading, nil)
        assert_fixture_report(command + ['example.txt'], directory, { 'Text/HardTabs' => 1 })
      end
    end
  end

  %w[markdown text].each do |format|
    IntegrationFixtures.cases(format).each do |fixture, data|
      next unless %w[defaults custom_extension].include?(File.basename(fixture))

      it "boots, discovers, and checks #{format}/#{File.basename(fixture)} through the executable" do
        scenario = File.basename(fixture)
        Dir.mktmpdir('cli-smoke-') do |directory|
          FileUtils.cp_r(File.join(fixture, '.'), directory)
          input = Dir.glob(File.join(directory, 'input.*')).fetch(0)
          filename = "example#{File.extname(input)}"
          file = File.join(directory, filename)
          source = File.binread(input)
          expected = File.binread(File.join(fixture, "expected#{File.extname(input)}"))
          FileUtils.mv(input, file)
          Dir.glob(File.join(directory, 'expected.*')).each { |path| FileUtils.rm(path) }
          configuration = File.join(directory, '.rubocop.yml')
          command = fixture_command(configuration, [], 'config', nil)

          if scenario == 'custom_extension'
            assert_fixture_report(command, directory, data.fetch('offenses'))
          else
            assert_fixture_report(command + [filename], directory, data.fetch('offenses'))
            assert_fixture_report(command + ['--stdin', filename], directory, data.fetch('offenses'),
                                  stdin_data: source)
            expect(File.binread(file)).to eq(source)
            config = YAML.safe_load_file(configuration)
            config.delete('plugins')
            File.write(configuration, config.to_yaml)
            command = fixture_command(configuration, [], 'options', nil)
            assert_fixture_report(command, directory, data.fetch('offenses'))
            2.times do
              assert_fixture_report(command + ['-a', filename], directory, data.fetch('remaining_offenses'),
                                    corrected: true)
              expect(File.binread(file)).to eq(expected)
            end
          end
          expect(File.binread(file)).to eq(source) if scenario == 'custom_extension'
        end
      end

      %w[markdown text].each do |format|
        IntegrationFixtures.cases(format).each do |fixture, data|
          next unless File.basename(fixture) == 'sentence_capitalization'

          %w[options config].each do |loading|
            it "checks #{format} sentence capitalization in a fresh process with #{loading} loading" do
              run_fixture(fixture, data, loading, nil)
            end
          end
        end
      end
    end
  end
end
