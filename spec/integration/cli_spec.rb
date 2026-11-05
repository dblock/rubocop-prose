# frozen_string_literal: true

RSpec.describe 'Fresh-process CLI smoke tests' do
  it 'rejects obsolete list spacing settings through both plugin loading mechanisms' do
    Dir.mktmpdir('cli-obsolete-') do |directory|
      configuration = File.join(directory, '.rubocop.yml')
      File.write(File.join(directory, 'example.md'), "1. one\n")
      %w[config options].each do |loading|
        config = { 'Markdown/ListMarkerSpacing' => { 'OrderedSingle' => 2 } }
        config['plugins'] = ['rubocop-prose'] if loading == 'config'
        File.write(configuration, config.to_yaml)
        command = fixture_command(configuration, [], loading, nil)
        command.insert(1, '-W1')
        stdout, stderr, status = Open3.capture3(*command, 'example.md', chdir: directory)
        expect(status.exitstatus).to eq(2)
        expect(stdout + stderr).to include('OrderedSingle', 'EnforcedStyle', 'MinSpaces')
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
    end
  end
end
