# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Prose::BlockquoteBlankLines do
  it 'fills unmarked blank lines between adjacent quotes' do
    source = "> first\n\n> second\n"
    expect(offenses(described_class, source).size).to eq(1)
    result = corrected(described_class, source)
    expect(result).to eq("> first\n>\n> second\n")
    expect(offenses(described_class, result)).to be_empty
  end

  it 'retains outer quote markers when connecting nested quotes' do
    expect(corrected(described_class, "> > first\n>\n> > second\n")).to eq("> > first\n> >\n> > second\n")
  end

  it 'does not merge quotes separated by content or inspect code examples' do
    expect(offenses(described_class, "> first\n\noutside\n\n> second\n\n```\n> a\n\n> b\n```\n")).to be_empty
  end
end
