# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Prose::MultipleBlankLines do
  it 'reduces excess blank lines without merging paragraphs and stabilizes' do
    result = corrected(described_class, "First.\n\n\n\nSecond.\n")
    expect(result).to eq("First.\n\nSecond.\n")
    expect(offenses(described_class, result)).to be_empty
  end

  it 'retains blanks inside code and front matter' do
    source = "---\ntext: |\n\n\n  metadata\n---\n\n```\none\n\n\nthree\n```\n"
    expect(corrected(described_class, source)).to eq(source)
  end

  it 'allows configured limits but reports zero without deleting paragraph separation' do
    source = "First.\n\nSecond.\n"
    expect(offenses(described_class, source, 'Max' => 2)).to be_empty
    expect(offenses(described_class, source, 'Max' => 0).length).to eq(1)
    expect(corrected(described_class, source, 'Max' => 0)).to eq(source)
  end
end
