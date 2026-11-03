# frozen_string_literal: true

RSpec.describe 'Composed prose cops' do
  it 'does not duplicate specialized undefined-reference diagnostics through Syntax' do
    classes = [RuboCop::Cop::Prose::Syntax, RuboCop::Cop::Prose::UndefinedReference]
    result = investigate(classes, "A [label][missing].\n").first
    expect(result.map(&:cop_name)).to eq(['Prose/UndefinedReference'])
  end

  it 'does not duplicate specialized definition diagnostics through Syntax' do
    classes = [RuboCop::Cop::Prose::Syntax, RuboCop::Cop::Prose::ReferenceDefinitions]
    result = investigate(classes, "[id]: /one\n[id]: /two\n").first
    expect(result).not_to be_empty
    expect(result.map(&:cop_name).uniq).to eq(['Prose/ReferenceDefinitions'])
  end

  it 'does not interpret hidden directive examples inside code as suppression commands' do
    source = "```\n<!-- # rubocop:disable Prose/MaxLength -->\n```\n\nA long line of prose.\n"
    expect(offenses(RuboCop::Cop::Prose::MaxLength, source, 'Max' => 10)).not_to be_empty
  end

  it 'stabilizes combined paragraph, whitespace, and final-newline corrections through the CLI' do
    Dir.mktmpdir('prose-composition') do |directory|
      file = File.join(directory, 'example.md')
      configuration = File.join(directory, '.rubocop.yml')
      File.write(file, "Some\nprose.   \n\n\n")
      File.write(configuration, {
        'AllCops' => { 'NewCops' => 'enable' },
        'Prose/MaxLength' => { 'Enabled' => true, 'Max' => false },
        'Prose/TrailingWhitespace' => { 'Enabled' => true },
        'Prose/TrailingNewline' => { 'Enabled' => true }
      }.to_yaml)
      command = ['bundle', 'exec', 'rubocop', '--plugin', 'rubocop-prose',
                 '--config', configuration, '--cache', 'false', '--format', 'json',
                 '--only', 'Prose/MaxLength,Prose/TrailingWhitespace,Prose/TrailingNewline', '-a', file]
      stdout, stderr, status = Open3.capture3(*command)
      expect(status.exitstatus).to eq(0), "#{stdout}\n#{stderr}"
      expect(File.read(file)).to eq("Some prose.  \n")
      stdout, stderr, status = Open3.capture3(*command)
      expect(status.exitstatus).to eq(0), "#{stdout}\n#{stderr}"
      expect(JSON.parse(stdout).fetch('summary').fetch('offense_count')).to eq(0)
    end
  end
end
