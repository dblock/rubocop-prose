# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Markdown::EmphasisStyle do
  it 'rejects unsupported styles explicitly, even without emphasis' do
    ['invalid', nil, ['asterisk']].each do |style|
      expect do
        offenses(described_class, '', 'Style' => style)
      end.to raise_error(RuboCop::ValidationError, /Style must be one of consistent, asterisk, underscore/)
    end
  end

  it 'honors an explicit asterisk policy' do
    source = "_first_ and *second*\n"
    expected = "*first* and *second*\n"
    expect(corrected(described_class, source, 'Style' => 'asterisk')).to eq(expected)
    expect(offenses(described_class, expected, 'Style' => 'asterisk')).to be_empty
  end

  it 'uses the first parsed emphasis style in consistent mode' do
    source = "_first_ and *second*.\n"
    expect(offenses(described_class, source).size).to eq(1)
    expect(corrected(described_class, source)).to eq("_first_ and _second_.\n")
  end

  it 'corrects configured emphasis, including nesting and multiline spans' do
    source = "> ***nested*** and *two\n> words*.\n"
    expected = "> **_nested_** and _two\n> words_.\n"
    expect(corrected(described_class, source, { 'Style' => 'underscore' })).to eq(expected)
    expect(offenses(described_class, expected, { 'Style' => 'underscore' })).to be_empty
  end

  it 'does not change strong emphasis, code, links, escaped delimiters, or HTML' do
    source = "**strong** `*code*` [*link*](url) \\*escaped* <b>*html*</b>\n"
    expect(offenses(described_class, source, { 'Style' => 'underscore' })).to be_empty
  end

  it 'reports intraword asterisks without an unsafe underscore correction' do
    source = "before*middle*after\n"
    expect(offenses(described_class, source, { 'Style' => 'underscore' }).size).to eq(1)
    expect(corrected(described_class, source, { 'Style' => 'underscore' })).to eq(source)
  end

  it 'preserves source positions after Unicode text and list prefixes' do
    source = "- café *word*\n"
    expect(corrected(described_class, source, { 'Style' => 'underscore' })).to eq("- café _word_\n")
  end

  it 'maps emphasis in table cells without touching code or link labels' do
    source = "| *word* | *[link](url)* |\n| --- | --- |\n| `*code*` | [*link*](url) |\n"
    expected = "| _word_ | _[link](url)_ |\n| --- | --- |\n| `*code*` | [*link*](url) |\n"
    expect(corrected(described_class, source, { 'Style' => 'underscore' })).to eq(expected)
  end
end
