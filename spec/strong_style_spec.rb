# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Markdown::StrongStyle do
  it 'uses the first parsed strong style in consistent mode' do
    source = "__first__ and **second**.\n"
    expect(offenses(described_class, source).size).to eq(1)
    expect(corrected(described_class, source)).to eq("__first__ and __second__.\n")
  end

  it 'corrects configured strong delimiters without changing nested emphasis' do
    source = "***nested*** and **two\nwords**.\n"
    expected = "__*nested*__ and __two\nwords__.\n"
    expect(corrected(described_class, source, { 'Style' => 'underscore' })).to eq(expected)
    expect(offenses(described_class, expected, { 'Style' => 'underscore' })).to be_empty
  end

  it 'does not change emphasis, code, links, escaped delimiters, or HTML' do
    source = "*em* `**code**` [**link**](url) \\*\\*escaped** <b>**html**</b>\n"
    expect(offenses(described_class, source, { 'Style' => 'underscore' })).to be_empty
  end

  it 'reports intraword asterisks without an unsafe underscore correction' do
    source = "before**middle**after\n"
    expect(offenses(described_class, source, { 'Style' => 'underscore' }).size).to eq(1)
    expect(corrected(described_class, source, { 'Style' => 'underscore' })).to eq(source)
  end

  it 'does not treat unparsed underscore words as strong emphasis' do
    expect(offenses(described_class, "one__two__three\n", { 'Style' => 'asterisk' })).to be_empty
  end

  it 'maps strong emphasis in table cells without touching inline code' do
    source = "| **word** | `**code**` |\n| --- | --- |\n"
    expected = "| __word__ | `**code**` |\n| --- | --- |\n"
    expect(corrected(described_class, source, { 'Style' => 'underscore' })).to eq(expected)
  end
end
