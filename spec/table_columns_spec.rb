# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Prose::TableColumns do
  it 'reports too few and too many body columns even when GFM rejects the table' do
    source = "| a | b |\n| --- | --- |\n| x |\n| x | y | z |\n"
    expect(offenses(described_class, source).map(&:line)).to eq([3, 4])
    expect(corrected(described_class, source)).to eq(source)
  end

  it 'also reports a mismatched delimiter row' do
    source = "| a | b |\n| --- |\n| x | y |\n"
    expect(offenses(described_class, source).map(&:line)).to eq([2])
  end

  it 'counts empty cells while ignoring escaped pipes and inline backticks' do
    source = "| a | b | c |\n| --- | --- | --- |\n| `x|y` | q\\|r | |\n| ``x`|y`` | z | |\n| [`x|y`](url) | z | |\n"
    expect(offenses(described_class, source)).to be_empty
  end

  it 'supports tables without outer pipes and blockquote tables' do
    source = "> a | b\n> --- | ---\n> x | y\n"
    expect(offenses(described_class, source)).to be_empty
  end

  it 'ignores HTML blocks, fenced code, and text without a table delimiter row' do
    source = "<div>\n| a | b |\n| --- | --- |\n| x |\n</div>\n\n```\n| a | b |\n| --- | --- |\n| x |\n```\n\nx | y | z\n"
    expect(offenses(described_class, source)).to be_empty
  end
end
