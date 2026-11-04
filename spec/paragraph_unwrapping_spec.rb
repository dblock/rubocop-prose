# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Prose::MaxLength do
  let(:cop) { described_class }

  it 'preserves nested prefixes, Unicode locations, and task-list markers' do
    source = "> - [x] Hello \u{1f600}\n>   world.\n"
    expect(corrected(cop, source, 'Max' => false)).to eq("> - [x] Hello \u{1f600} world.\n")
    expect(offenses(cop, source, 'Max' => false).first.line).to eq(2)
  end
end
