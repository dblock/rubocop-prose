# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Markdown::TableSpacing do
  it 'rejects unsupported styles explicitly, even without tables' do
    ['invalid', nil, ['compact']].each do |style|
      expect do
        offenses(described_class, '', 'Style' => style)
      end.to raise_error(RuboCop::ValidationError, /Style must be one of aligned, compact, tight/)
    end
  end

  it 'pads aligned cells to the widest source content in each column' do
    source = "| a|long |\n|---|---|\n|xx| y|\n"
    expected = "| a   | long |\n| --- | ---  |\n| xx  | y    |\n"
    expect(corrected(described_class, source)).to eq(expected)
    expect(offenses(described_class, expected)).to be_empty
  end

  it 'uses exactly one space in compact mode' do
    source = "|  a|b  |\n|---|---|\n| x  |  y |\n"
    expected = "| a | b |\n| --- | --- |\n| x | y |\n"
    settings = { 'Style' => 'compact' }
    expect(corrected(described_class, source, settings)).to eq(expected)
    expect(offenses(described_class, expected, settings)).to be_empty
  end

  it 'removes padding in tight mode without changing inline contents' do
    source = "| ` x|y ` | a\\|b |\n| :--- | ---: |\n| two  words | `` `x` `` |\n"
    expected = "|` x|y `|a\\|b|\n|:---|---:|\n|two  words|`` `x` ``|\n"
    settings = { 'Style' => 'tight' }
    expect(corrected(described_class, source, settings)).to eq(expected)
    expect(offenses(described_class, expected, settings)).to be_empty
  end

  it 'does not add exterior padding when outer pipes are absent' do
    source = "a|b\n---|---\nx|y\n"
    expect(corrected(described_class, source, { 'Style' => 'compact' })).to eq("a | b\n--- | ---\nx | y\n")
  end

  it 'preserves empty cells and excludes code blocks' do
    source = "| | b |\n| --- | --- |\n| | y |\n\n```\n|a|b|\n|---|---|\n```\n"
    expect(offenses(described_class, source, { 'Style' => 'compact' })).to be_empty
  end
end
