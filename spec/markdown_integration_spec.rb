# frozen_string_literal: true

RSpec.describe 'rubocop-md interoperability' do
  %w[prose_first markdown_first].each do |order|
    it "composes Ruby and prose corrections with #{order} loading" do
      markdown_path = ENV.fetch('RUBOCOP_MD_PATH', nil)
      skip 'Set RUBOCOP_MD_PATH to a rubocop-md checkout with original-source mapping.' unless markdown_path

      Dir.mktmpdir('prose-markdown') do |directory|
        file = File.join(directory, 'example.md')
        configuration = File.join(directory, '.rubocop.yml')
        source = "\u{1f600} First\ncontinues.\n\n> ```ruby\n> puts 'hello'\n> ```\n"
        File.write(file, source)
        File.write(configuration, {
          'AllCops' => { 'NewCops' => 'enable' },
          'Prose/MaxLength' => { 'Enabled' => true, 'Max' => false },
          'Style/StringLiterals' => { 'Enabled' => true, 'EnforcedStyle' => 'double_quotes' }
        }.to_yaml)
        requires = order == 'prose_first' ? %w[rubocop-prose rubocop-md] : %w[rubocop-md rubocop-prose]
        command = ['bundle', 'exec', 'ruby', '-Ilib', "-I#{File.join(markdown_path, 'lib')}", '-rrubocop',
                   *requires.map { |name| "-r#{name}" }, '-S', 'rubocop', '--plugin', 'rubocop-prose',
                   '--config', configuration, '--cache', 'false', '--format', 'json',
                   '--only', 'Prose/MaxLength,Style/StringLiterals', '-a', file]
        stdout, stderr, status = Open3.capture3(*command)
        expect(status.exitstatus).to eq(0), "#{stdout}\n#{stderr}"
        expected = "\u{1f600} First continues.\n\n> ```ruby\n> puts \"hello\"\n> ```\n"
        expect(File.read(file)).to eq(expected)
        stdout, stderr, status = Open3.capture3(*command)
        expect(status.exitstatus).to eq(0), "#{stdout}\n#{stderr}"
        expect(JSON.parse(stdout).fetch('summary').fetch('offense_count')).to eq(0)
        expect(File.read(file)).to eq(expected)
        stdin_command = command[0...-1].reject { |argument| argument == '-a' } + ['--stdin', file]
        stdout, stderr, status = Open3.capture3(*stdin_command, stdin_data: source)
        expect(status.exitstatus).to eq(1), "#{stdout}\n#{stderr}"
        expect(JSON.parse(stdout).fetch('summary').fetch('offense_count')).to eq(2)
        expect(File.read(file)).to eq(expected)
      end
    end
  end
end
