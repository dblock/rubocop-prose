# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Prose::HardTabs do
  it 'reports exact Unicode-aware tab locations without guessing a correction' do
    source = "Hello \u{1f600}\tworld.\n"
    result = offenses(described_class, source)
    expect(result.map(&:column)).to eq([7])
    expect(corrected(described_class, source)).to eq(source)
  end

  it 'allows configured code languages or all code to be excluded' do
    source = "```make\n\ttarget:\n```\n"
    expect(offenses(described_class, source).map(&:line)).to eq([2])
    expect(offenses(described_class, source, 'AllowedCodeLanguages' => ['make'])).to be_empty
    expect(offenses(described_class, source, 'CodeBlocks' => false)).to be_empty
  end

  it 'does not report front matter or tab-free prose' do
    expect(offenses(described_class, "---\ntitle:\tvalue\n---\n\nText.\n")).to be_empty
  end
end
