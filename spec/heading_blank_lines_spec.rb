# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Markdown::HeadingBlankLines do
  it 'reports missing surrounding blank lines' do
    expect(offenses(described_class, "Before\n# Title\nAfter\n").map(&:line)).to eq([2])
  end

  it 'accepts surrounding blank lines and document boundaries' do
    expect(offenses(described_class, "# Title\n\nText\n\n## End\n")).to be_empty
  end

  it 'measures Setext headings after their underline' do
    expect(offenses(described_class, "Title\n=====\nText\n").map(&:line)).to eq([1])
    expect(offenses(described_class, "Title\n=====\n\nText\n")).to be_empty
  end

  it 'supports independently configured blank-line counts' do
    options = { 'LinesAbove' => 2, 'LinesBelow' => 0 }
    expect(offenses(described_class, "Text\n\n# Title\nMore\n", options).size).to eq(1)
    expect(offenses(described_class, "Text\n\n\n# Title\nMore\n", options)).to be_empty
  end

  it 'accepts front matter boundaries and blank blockquote lines' do
    expect(offenses(described_class, "---\ntitle: Test\n---\n# Title\n")).to be_empty
    expect(offenses(described_class, "> Text\n>\n> # Title\n>\n> More\n")).to be_empty
  end

  it 'ignores code and does not insert blank lines' do
    expect(offenses(described_class, "```\n# Code\nText\n```\n")).to be_empty
    source = "Before\n# Title\nAfter\n"
    expect(corrected(described_class, source)).to eq(source)
  end
end
