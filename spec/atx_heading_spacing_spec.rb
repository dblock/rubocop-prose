# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Markdown::AtxHeadingSpacing do
  it 'reports excess opening spacing' do
    expect(offenses(described_class, "##  Résumé\n").size).to eq(1)
  end

  it 'accepts one separator and empty headings' do
    expect(offenses(described_class, "# Title\n\n##\tDetail\n\n###   \n")).to be_empty
  end

  it 'preserves Unicode and container prefixes when correcting' do
    source = "> ## \t Résumé #\n"
    result = corrected(described_class, source)
    expect(result).to eq("> ## Résumé #\n")
    expect(offenses(described_class, result)).to be_empty
    expect(corrected(described_class, result)).to eq(result)
  end

  it 'ignores escaped markers, front matter and code' do
    source = "---\ntitle: '#  Title'\n---\n\\#  Text\n\n```\n#  Code\n```\n\n    #  Code\n"
    expect(offenses(described_class, source)).to be_empty
  end

  it 'does not alter trailing whitespace' do
    expect(corrected(described_class, "#  Title  \n")).to eq("# Title  \n")
  end
end
