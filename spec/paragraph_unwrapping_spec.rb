# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Prose::MaxLength, 'paragraph unwrapping' do
  let(:cop) { described_class }

  it 'joins soft breaks but keeps paragraphs separate and stabilizes' do
    result = corrected(cop, "First\nparagraph.\n\nSecond\nparagraph.\n", 'Max' => false)
    expect(result).to eq("First paragraph.\n\nSecond paragraph.\n")
    expect(corrected(cop, result, 'Max' => false)).to eq(result)
  end

  it 'preserves nested prefixes, Unicode locations, and task-list markers' do
    source = "> - [x] Hello \u{1f600}\n>   world.\n"
    expect(corrected(cop, source, 'Max' => false)).to eq("> - [x] Hello \u{1f600} world.\n")
    expect(offenses(cop, source, 'Max' => false).first.line).to eq(2)
  end

  it 'preserves hard breaks, inline-code newlines, and HTML break boundaries' do
    sources = ["First  \nsecond.\n", "First\\\nsecond.\n", "Some `inline\ncode` here.\n",
               "First<br>\nsecond.\n", "First\n<br>second.\n"]
    sources.each { |source| expect(corrected(cop, source, 'Max' => false)).to eq(source) }
  end

  it 'does not unwrap code or raw HTML blocks' do
    source = "```ruby\nputs 1\nputs 2\n```\n\n<div>\nHTML\n</div>\n"
    expect(corrected(cop, source, 'Max' => false)).to eq(source)
  end
end
