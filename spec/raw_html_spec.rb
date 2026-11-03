# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Prose::RawHtml do
  it 'reports parser-recognized inline and block HTML' do
    source = "<div>\n<b>hello</b>\n</div>\n\nText <i>world</i>.\n"
    expect(offenses(described_class, source).map(&:line)).to eq([1, 2, 5])
  end

  it 'allows configured elements without case sensitivity' do
    expect(offenses(described_class, "Text <br> <b>bold</b>.\n",
                    { 'AllowedElements' => ['BR'] }).size).to eq(1)
  end

  it 'does not interpret code, comments, escaped HTML, or autolinks as elements' do
    source = "`<b>` <!-- comment --> <https://example.com> \\<i>\n\n```\n<div>\n```\n"
    expect(offenses(described_class, source)).to be_empty
  end

  it 'maps repeated elements and multiline opening tags' do
    source = "Text <b>one</b> <b>two</b>.\n\n<div\n class=\"x\">\ntext\n</div>\n"
    found = offenses(described_class, source)
    expect(found.map(&:line)).to eq([1, 1, 3])
    expect(found.first(2).map(&:column)).to eq([5, 16])
  end

  it 'ignores front matter and does not autocorrect HTML' do
    source = "---\ntitle: <b>name</b>\n---\n\nText <b>name</b>.\n"
    expect(offenses(described_class, source).size).to eq(1)
    expect(corrected(described_class, source)).to eq(source)
  end

  it 'maps HTML in table cells while ignoring code and autolinks' do
    source = "| a | b |\n| --- | --- |\n| <b>x</b> | `<b>` |\n"
    expect(offenses(described_class, source).map(&:line)).to eq([3])
  end
end
