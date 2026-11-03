# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Markdown::UnorderedListIndentation do
  it 'reports a nested list with the wrong width without unsafe correction' do
    source = "- parent\n    - child\n"
    expect(offenses(described_class, source).size).to eq(1)
    expect(corrected(described_class, source)).to eq(source)
  end

  it 'accepts configured indentation inside quotes' do
    expect(offenses(described_class, "> - parent\n>     - child\n", 'Indent' => 4)).to be_empty
  end

  it 'does not check ordered items or code' do
    expect(offenses(described_class, "  1. ordered\n\n```\n   - example\n```\n")).to be_empty
  end

  it 'starts a fresh indentation baseline inside a nested quote container' do
    expect(offenses(described_class, "- parent\n  > - child\n")).to be_empty
    expect(offenses(described_class, "- > - child\n")).to be_empty
  end
end
