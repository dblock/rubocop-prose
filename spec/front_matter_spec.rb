# frozen_string_literal: true

RSpec.describe 'Prose front matter configuration' do
  let(:cop) { RuboCop::Cop::Prose::MaxLength }
  let(:source) { "---\ntitle: First\nsummary: Second\n...\n\nBody stays.\n" }

  it 'ignores closed leading metadata by default' do
    expect(corrected(cop, source, 'Max' => false)).to eq(source)
  end

  it 'can treat metadata as ordinary Markdown without validating YAML' do
    result = corrected(cop, source, { 'Max' => false }, settings: { 'Prose' => { 'IgnoreFrontMatter' => false } })
    expect(result).to eq("---\ntitle: First summary: Second ...\n\nBody stays.\n")
  end

  it 'does not exclude unclosed or non-initial delimiters' do
    ["---\nFirst\nsecond.\n", "Introduction.\n\n---\nFirst\nsecond.\n"].each do |text|
      expect(corrected(cop, text, 'Max' => false)).to include('First second.')
    end
  end

  it 'rejects invalid settings explicitly' do
    expect do
      offenses(cop, source, { 'Max' => false }, settings: { 'Prose' => { 'IgnoreFrontMatter' => 'yes' } })
    end.to raise_error(RuboCop::ValidationError, /IgnoreFrontMatter/)
  end
end
