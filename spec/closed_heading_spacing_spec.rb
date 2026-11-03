# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Prose::ClosedHeadingSpacing do
  it 'reports excess closing spacing' do
    expect(offenses(described_class, "# Title  ##\n").size).to eq(1)
  end

  it 'accepts one separator and non-closed headings' do
    expect(offenses(described_class, "# Title #\n\n## Title\t##\n\n# Title\n")).to be_empty
  end

  it 'corrects only the separator and remains idempotent' do
    result = corrected(described_class, "> ## Résumé \t ###  \n")
    expect(result).to eq("> ## Résumé ###  \n")
    expect(offenses(described_class, result)).to be_empty
    expect(corrected(described_class, result)).to eq(result)
  end

  it 'ignores escaped suffixes and code' do
    expect(offenses(described_class, "# Title  \\#\n\n```\n# Code  #\n```\n\n    # Code  #\n")).to be_empty
  end

  it 'leaves attached literal suffixes alone' do
    expect(offenses(described_class, "# Title#\n")).to be_empty
  end
end
