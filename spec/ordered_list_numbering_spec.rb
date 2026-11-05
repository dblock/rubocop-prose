# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Markdown::OrderedListNumbering do
  it 'migrates the released EnforcedStyle setting to Style' do
    config = RuboCop::Config.new(
      { 'Markdown/OrderedListNumbering' => { 'EnforcedStyle' => 'sequential' } }, '.rubocop.yml'
    )
    expect { RuboCop::ConfigObsoletion.new(config).reject_obsolete! }
      .to raise_error(RuboCop::ValidationError, /obsolete parameter `EnforcedStyle`.*Style/m)
  end

  it 'corrects sequential numbering relative to the first number' do
    source = "3. three\n3. four\n"
    expect(offenses(described_class, source).size).to eq(1)
    result = corrected(described_class, source)
    expect(result).to eq("3. three\n4. four\n")
    expect(offenses(described_class, result)).to be_empty
  end

  it 'supports repeated ones inside quotes' do
    expect(corrected(described_class, "> 2. two\n> 3. three\n", 'Style' => 'ones')).to eq("> 1. two\n> 1. three\n")
  end

  it 'reports width-changing fixes without altering continuation indentation' do
    source = "9. nine\n1. ten\n"
    expect(offenses(described_class, source).size).to eq(1)
    expect(corrected(described_class, source)).to eq(source)
  end

  it 'ignores unordered lists and fenced examples' do
    expect(offenses(described_class, "- one\n\n```\n1. one\n3. three\n```\n")).to be_empty
  end
end
