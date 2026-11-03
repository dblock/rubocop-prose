# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Prose::TrailingNewline do
  it 'inserts a missing newline at the actual EOF' do
    expect(corrected(described_class, "Unicode \u{1f600}")).to eq("Unicode \u{1f600}\n")
  end

  it 'normalizes excess final blank lines and stabilizes' do
    result = corrected(described_class, "Text.\n\n\n")
    expect(result).to eq("Text.\n")
    expect(offenses(described_class, result)).to be_empty
  end

  it 'accepts empty documents and a single final newline' do
    expect(offenses(described_class, '')).to be_empty
    expect(offenses(described_class, "Text.\n")).to be_empty
  end
end
