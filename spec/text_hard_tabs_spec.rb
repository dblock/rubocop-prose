# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Text::HardTabs do
  it 'reports tabs literally throughout plain text and never corrects them' do
    source = "```make\tlabel\n\tcommand\n---\nmetadata:\tvalue\n😀\ttext\n"
    found = offenses(described_class, source, path: 'example.txt')
    expect(found.map { |offense| [offense.line, offense.column] }).to eq([[1, 7], [2, 0], [4, 9], [5, 1]])
    expect(corrected(described_class, source, path: 'example.txt')).to eq(source)
  end

  it 'does not inspect Markdown even when selected explicitly' do
    expect(offenses(described_class, "A\tparagraph.\n")).to be_empty
  end
end
