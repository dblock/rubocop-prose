# frozen_string_literal: true

RSpec.describe 'RuboCop plugin CLI' do
  %w[options config].each do |mode|
    it "loads via #{mode} and autocorrects real Markdown files" do
      Dir.mktmpdir('rubocop-prose') do |directory|
        file = File.join(directory, 'example.md')
        configuration = File.join(directory, '.rubocop.yml')
        File.write(file, "First line\ncontinues here.\n")
        settings = { 'AllCops' => { 'NewCops' => 'enable' },
                     'Prose/MaxLength' => { 'Enabled' => true, 'Max' => false } }
        settings['plugins'] = ['rubocop-prose'] if mode == 'config'
        File.write(configuration, settings.to_yaml)
        command = ['bundle', 'exec', 'rubocop', '--config', configuration, '--cache', 'false',
                   '--only', 'Prose/MaxLength', '--format', 'json', '-a', file]
        command.push('--plugin', 'rubocop-prose') if mode == 'options'
        stdout, stderr, status = Open3.capture3(*command)
        expect(status.exitstatus).to eq(0), "#{stdout}\n#{stderr}"
        expect(JSON.parse(stdout).fetch('summary').fetch('offense_count')).to eq(1)
        expect(File.read(file)).to eq("First line continues here.\n")
      end
    end
  end
end
