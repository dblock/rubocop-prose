# frozen_string_literal: true

RSpec.describe RuboCop::Prose::FileTypes do
  def configuration(settings)
    RuboCop::Config.new(settings)
  end

  it 'uses native file patterns without affecting other configurations or front-matter defaults' do
    config = configuration('Markdown' => { 'Include' => [] },
                           'Text' => { 'Include' => ['**/*.notes', '**/LICENSE'] })
    expect(RuboCop::Prose::Document.format('file.notes', config)).to eq(:text)
    expect(RuboCop::Prose::Document.format('docs/LICENSE', config)).to eq(:text)
    expect(RuboCop::Prose::Document.format('file.NOTES', config)).to be_nil
    expect(RuboCop::Prose::Document.format('file.md', config)).to be_nil
    expect(RuboCop::Prose::Document.format('file.md')).to eq(:markdown)
    expect(configuration({}).prose_file_types.format('file.tXt')).to eq(:text)
    expect(RuboCop::Prose.default_configuration.fetch('Markdown')).to include(
      'IgnoreFrontMatter' => true, 'Include' => an_instance_of(Array)
    )
  end

  it 'accepts Pathname sources when RuboCop inspects the project gemspec' do
    path = Pathname.new(File.expand_path('../rubocop-prose.gemspec', __dir__))
    expect(RuboCop::ProcessedSource.from_file(path, 3.2).valid_syntax?).to be(true)
    expect(RuboCop::Prose::Document.format(Pathname.new('file.md'))).to eq(:markdown)
  end

  it 'rejects malformed lists and files that match both formats' do
    [nil, '*.txt', {}, [nil], ['']].each do |value|
      expect { configuration('Text' => { 'Include' => value }).prose_file_types }.to raise_error(RuboCop::ValidationError, %r{Text/Include must be an array})
    end
    expect do
      configuration('Markdown' => { 'Include' => ['docs/**/*'] },
                    'Text' => { 'Include' => ['**/*.txt'] }).prose_file_types.format('docs/file.txt')
    end.to raise_error(RuboCop::ValidationError, %r{matches both Markdown/Include and Text/Include})
  end

  it 'uses the configured format for parsing, directives, corrections, and cop applicability' do
    text = { 'Markdown' => { 'Include' => [] }, 'Text' => { 'Include' => ['**/*.notes'] } }
    markdown = { 'Markdown' => { 'Include' => ['**/*.notes'] }, 'Text' => { 'Include' => [] } }
    source = "<!-- # rubocop:disable Prose/MaxLength -->\nFirst\nsecond.\n"
    formatter = RuboCop::Cop::Prose::MaxLength
    expect(corrected(formatter, source, { 'Max' => false }, path: 'file.notes', settings: text)).to eq(
      "<!-- # rubocop:disable Prose/MaxLength --> First second.\n"
    )
    expect(corrected(formatter, source, { 'Max' => false }, path: 'file.notes', settings: markdown)).to eq(source)
    heading = RuboCop::Cop::Markdown::HeadingPunctuation
    expect(offenses(heading, "# Heading.\n", path: 'file.notes', settings: markdown).length).to eq(1)
    expect(offenses(heading, "# Heading.\n", path: 'file.notes', settings: text)).to be_empty
    whitespace = RuboCop::Cop::Text::TrailingWhitespace
    expect(corrected(whitespace, "Text \t\n", path: 'file.notes', settings: text)).to eq("Text\n")
    processed = RuboCop::ProcessedSource.new("Not Ruby.\n", 3.2, 'file.notes',
                                             prose_configuration: configuration(text))
    expect(processed.ast).to be_nil
    expect(processed.diagnostics).to be_empty
  end

  it 'honors inherited per-directory configuration and exclusions during discovery in one run' do
    Dir.mktmpdir('prose-file-types') do |directory|
      directory = File.realpath(directory)
      FileUtils.mkdir_p(File.join(directory, 'child'))
      File.write(File.join(directory, '.rubocop.yml'), {
        'AllCops' => { 'NewCops' => 'disable' },
        'Markdown' => { 'Include' => ['**/*.notes'] }, 'Text' => { 'Include' => [] }
      }.to_yaml)
      File.write(File.join(directory, 'child/.rubocop.yml'), {
        'inherit_from' => '../.rubocop.yml',
        'AllCops' => { 'Exclude' => ['skip.notes'] },
        'Markdown' => { 'Include' => [] }, 'Text' => { 'Include' => ['**/*.NOTES', '**/*.notes'] }
      }.to_yaml)
      %w[root.notes child/nested.NOTES child/skip.notes old.md old.txt].each do |file|
        File.write(File.join(directory, file), "First\nsecond.\n")
      end
      Dir.chdir(directory) do
        store = RuboCop::ConfigStore.new
        root = store.for_file('root.notes')
        nested = store.for_file('child/nested.NOTES')
        expect(root.prose_file_types.format('root.notes')).to eq(:markdown)
        expect(nested.prose_file_types.format('child/nested.NOTES')).to eq(:text)
        found = RuboCop::TargetFinder.new(store).find([directory], :only_recognized_file_types)
        expect(found.map { |file| file.delete_prefix("#{directory}/") }).to contain_exactly(
          'root.notes', 'child/nested.NOTES'
        )
        runner = RuboCop::Runner.new({ cache: false }, store)
        expect(runner.send(:get_processed_source, 'root.notes').prose_format).to eq(:markdown)
        expect(runner.send(:get_processed_source, 'child/nested.NOTES').prose_format).to eq(:text)
        expect(runner.send(:get_processed_source, 'root.notes').prose_format).to eq(:markdown)
      end
    end
  end
end
