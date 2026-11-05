# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Markdown::TablePipes do
  it 'rejects unsupported styles explicitly, even without tables' do
    ['invalid', nil, ['leading_only']].each do |style|
      expect do
        offenses(described_class, '', 'Style' => style)
      end.to raise_error(RuboCop::ValidationError, /Style must be one of consistent, leading_and_trailing/)
    end
  end

  { 'leading_only' => ['|', ''], 'trailing_only' => ['', '|'] }.each do |style, (leading, trailing)|
    it "supports #{style} without changing cell content" do
      source = "a | b\n--- | ---\nx | y\n"
      expected = source.lines.map { |line| "#{leading}#{line.chomp}#{trailing}\n" }.join
      expect(corrected(described_class, source, 'Style' => style)).to eq(expected)
      expect(offenses(described_class, expected, 'Style' => style)).to be_empty
    end
  end

  it 'matches the first row leading and trailing pipe style per table' do
    source = "| a | b |\n--- | ---\nx | y |\n"
    expected = "| a | b |\n|--- | ---|\n|x | y |\n"
    expect(offenses(described_class, source).size).to eq(2)
    expect(corrected(described_class, source)).to eq(expected)
    expect(offenses(described_class, expected)).to be_empty
  end

  it 'supports explicitly omitted outer pipes without losing content' do
    source = "| a | b |\n| --- | --- |\n| x | y |\n"
    expected = " a | b \n --- | --- \n x | y \n"
    settings = { 'Style' => 'no_leading_or_trailing' }
    expect(corrected(described_class, source, settings)).to eq(expected)
    expect(offenses(described_class, expected, settings)).to be_empty
  end

  it 'honors escaped pipes and matching backtick runs' do
    source = "a | b\n--- | ---\n`x|y` | z\\|q\n"
    expect(offenses(described_class, source)).to be_empty
  end

  it 'preserves blockquote prefixes and trailing whitespace' do
    source = "> a | b\n> --- | ---\n> x | y  \n"
    settings = { 'Style' => 'leading_and_trailing' }
    expect(corrected(described_class, source, settings)).to eq("> |a | b|\n> |--- | ---|\n> |x | y|  \n")
  end

  it 'does not remove outer pipes when that would erase an empty cell' do
    source = "| | b |\n| --- | --- |\n| x | y |\n"
    result = corrected(described_class, source, { 'Style' => 'no_leading_or_trailing' })
    expect(result.lines.first).to eq(source.lines.first)
  end

  it 'ignores code, front matter, and pipe-containing ordinary text' do
    source = "---\ntitle: a | b\n---\n\nordinary | text\n\n```\n|a|b|\n|---|---|\nx|y\n```\n"
    expect(offenses(described_class, source)).to be_empty
  end
end
