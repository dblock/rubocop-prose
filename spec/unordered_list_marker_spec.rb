# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Markdown::UnorderedListMarker do
  it 'migrates the released EnforcedStyle setting to Style' do
    config = RuboCop::Config.new(
      { 'Markdown/UnorderedListMarker' => { 'EnforcedStyle' => 'asterisk' } }, '.rubocop.yml'
    )
    expect { RuboCop::ConfigObsoletion.new(config).reject_obsolete! }
      .to raise_error(RuboCop::ValidationError, /obsolete parameter `EnforcedStyle`.*Style/m)
  end

  it 'uses the first unordered marker throughout the document' do
    source = "- one\n\n+ two\n"
    expect(offenses(described_class, source).size).to eq(1)
    expect(corrected(described_class, source)).to eq("- one\n\n- two\n")
    expect(offenses(described_class, corrected(described_class, source))).to be_empty
  end

  it 'supports a configured marker in nested quotes and lists' do
    source = "> - one\n>   + two\n"
    expect(corrected(described_class, source, 'Style' => 'asterisk')).to eq("> * one\n>   * two\n")
  end

  it 'ignores escapes, front matter, and code' do
    source = "---\na: + x\n---\n\\+ text\n\n```\n+ code\n```\n\n- item\n"
    expect(offenses(described_class, source, 'Style' => 'dash')).to be_empty
  end

  it 'does not turn a nested list into a thematic break' do
    source = "- * *\n"
    expect(offenses(described_class, source, 'Style' => 'asterisk').size).to eq(1)
    expect(corrected(described_class, source, 'Style' => 'asterisk')).to eq(source)
  end

  it 'considers all same-line marker corrections together' do
    source = "- + *\n"
    expect(offenses(described_class, source, 'Style' => 'asterisk')).not_to be_empty
    expect(corrected(described_class, source, 'Style' => 'asterisk')).to eq(source)
  end
end
