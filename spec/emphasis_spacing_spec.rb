# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Markdown::EmphasisSpacing do
  it 'removes inner edge whitespace from emphasis and strong emphasis' do
    source = "Text * loose * and ** bold ** and _ spaced_ and *** both ***.\n"
    expected = "Text *loose* and **bold** and _spaced_ and ***both***.\n"
    expect(offenses(described_class, source).size).to eq(4)
    expect(corrected(described_class, source)).to eq(expected)
    expect(offenses(described_class, expected)).to be_empty
  end

  it 'preserves internal whitespace and inline content' do
    source = "Text ** two  words ** and * [label](url) *.\n"
    expect(corrected(described_class, source)).to eq("Text **two  words** and *[label](url)*.\n")
  end

  it 'ignores valid emphasis, code, escaped delimiters, links, and HTML' do
    source = "*valid* **valid** *[label](url)* `* wrong *` \\* escaped * [* wrong *](url) <b>* wrong *</b>\n"
    expect(offenses(described_class, source)).to be_empty
  end

  it 'ignores multiline code, front matter, thematic breaks, and list markers' do
    source = "---\ntitle: '* wrong *'\n---\n\n***\n\n* list item *\n\n`` code\n* wrong *\ncode ``\n"
    expect(offenses(described_class, source)).to be_empty
  end
end
