# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Markdown::ThematicBreakStyle do
  it 'uses the first thematic break in consistent mode' do
    source = "***\n\n- - -\n"
    expect(offenses(described_class, source).size).to eq(1)
    expect(corrected(described_class, source)).to eq("***\n\n***\n")
  end

  it 'uses the configured literal spelling and preserves container prefixes' do
    source = "> ***\n\n  ___\n"
    expected = "> - - -\n\n  - - -\n"
    expect(corrected(described_class, source, { 'Style' => '- - -' })).to eq(expected)
    expect(offenses(described_class, expected, { 'Style' => '- - -' })).to be_empty
  end

  it 'accepts a positive list of literal spellings' do
    source = "Before.\n\n---\n\nBetween.\n\n-----\n\nAfter.\n"
    expect(offenses(described_class, source, { 'Style' => %w[--- -----] })).to be_empty
  end

  it 'reports disallowed spellings without choosing an ambiguous correction' do
    source = "é🙂\n\n> ---\n\n> -----\n\n> ***\n"
    report = offenses(described_class, source, { 'Style' => %w[--- -----] })

    expect(report.map { |offense| offense.location.source }).to eq(['***'])
    expect(report.first.location.line).to eq(7)
    expect(report.first.location.column).to eq(2)
    expect(report.first.correctable?).to be(false)
    expect(corrected(described_class, source, { 'Style' => %w[--- -----] })).to eq(source)
  end

  it 'corrects to the sole spelling in a one-item positive list' do
    source = "***\n"
    expect(corrected(described_class, source, { 'Style' => ['---'] })).to eq("---\n")
  end

  it 'rejects invalid configured thematic-break spellings' do
    ['not a break', [], ['---', 'not a break'], ['---  '], [nil], 3].each do |style|
      expect do
        offenses(described_class, "***\n", { 'Style' => style })
      end.to raise_error(RuboCop::ValidationError, /Style must be/)
    end
  end

  it 'does not treat setext headings, front matter, or code as thematic breaks' do
    source = "---\ntitle: example\n---\n\nHeading\n---\n\n```\n***\n```\n\n    ___\n"
    expect(offenses(described_class, source, { 'Style' => '---' })).to be_empty
  end

  it 'ignores trailing whitespace when comparing breaks' do
    expect(offenses(described_class, "***  \n\n***\n")).to be_empty
  end

  it 'does not infer a thematic break inside a parser-recognized paragraph' do
    source = "paragraph\n***\n"
    expect(offenses(described_class, source, { 'Style' => '---' })).to be_empty
    expect(corrected(described_class, source, { 'Style' => '---' })).to eq(source)
  end
end
