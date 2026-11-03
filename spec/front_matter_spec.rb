# frozen_string_literal: true

RSpec.describe 'Markdown front matter configuration' do
  let(:cop) { RuboCop::Cop::Prose::MaxLength }
  let(:source) { "---\ntitle: First\nsummary: Second\n...\n\nBody stays.\n" }

  it 'ignores closed leading metadata by default' do
    expect(corrected(cop, source, 'Max' => false)).to eq(source)
  end

  it 'can treat metadata as ordinary Markdown without validating YAML' do
    result = corrected(cop, source, { 'Max' => false }, settings: { 'Markdown' => { 'IgnoreFrontMatter' => false } })
    expect(result).to eq("---\ntitle: First summary: Second ...\n\nBody stays.\n")
  end

  it 'does not exclude unclosed or non-initial delimiters' do
    ["---\nFirst\nsecond.\n", "Introduction.\n\n---\nFirst\nsecond.\n"].each do |text|
      expect(corrected(cop, text, 'Max' => false)).to include('First second.')
    end
  end

  it 'rejects invalid settings explicitly' do
    expect do
      offenses(cop, source, { 'Max' => false }, settings: { 'Markdown' => { 'IgnoreFrontMatter' => 'yes' } })
    end.to raise_error(RuboCop::ValidationError, /IgnoreFrontMatter/)
  end

  it 'applies the same document setting to Markdown-specific cops' do
    heading = RuboCop::Cop::Markdown::HeadingPunctuation
    text = "---\n# Heading.\n---\n\nBody stays.\n"
    expect(offenses(heading, text)).to be_empty
    expect(offenses(heading, text, settings: { 'Markdown' => { 'IgnoreFrontMatter' => false } })
             .map(&:line)).to eq([2])
  end

  it 'keeps configured documents separate from the default document used for directives' do
    processed = RuboCop::ProcessedSource.new(source, 3.2, 'example.md')
    enabled = RuboCop::Config.new('Markdown' => { 'IgnoreFrontMatter' => true })
    disabled = RuboCop::Config.new('Markdown' => { 'IgnoreFrontMatter' => false })
    expect(processed.prose_document(configuration: disabled).front_matter_line?(2)).to be(false)
    expect(processed.prose_document(configuration: enabled).front_matter_line?(2)).to be(true)
    expect(processed.prose_document.front_matter_line?(2)).to be(true)
    expect(processed.prose_document(configuration: disabled).front_matter_line?(2)).to be(false)
  end
end
