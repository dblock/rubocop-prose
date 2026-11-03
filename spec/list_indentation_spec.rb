# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Markdown::ListIndentation do
  it 'reports inconsistent parsed siblings without moving their contents' do
    source = "- one\n - two\n"
    expect(offenses(described_class, source).size).to eq(1)
    expect(corrected(described_class, source)).to eq(source)
  end

  it 'checks ordered lists and quoted lists' do
    expect(offenses(described_class, "> 1. one\n>  2. two\n").size).to eq(1)
  end

  it 'compares siblings, not independent or nested lists' do
    expect(offenses(described_class, "- one\n  - nested\n  - sibling\n- two\n")).to be_empty
    expect(offenses(described_class, "```\n- one\n - two\n```\n")).to be_empty
  end
end
