# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Prose::TableBlankLines do
  it 'inserts surrounding blank lines without changing table content' do
    source = "before\n| a | b |\n| --- | --- |\n| x | y |\nafter\n"
    expected = "before\n\n| a | b |\n| --- | --- |\n| x | y |\n\nafter\n"
    expect(offenses(described_class, source).size).to eq(2)
    expect(corrected(described_class, source)).to eq(expected)
    expect(offenses(described_class, expected)).to be_empty
  end

  it 'accepts document boundaries and whitespace-only blank lines' do
    expect(offenses(described_class, "| a | b |\n| --- | --- |\n| x | y |\n")).to be_empty
    expect(offenses(described_class, "before\n \t\n| a | b |\n| --- | --- |\n \t\nafter\n")).to be_empty
  end

  it 'keeps inserted blank lines inside a blockquote' do
    source = "> before\n> | a | b |\n> | --- | --- |\n> | x | y |\n> after\n"
    expected = "> before\n>\n> | a | b |\n> | --- | --- |\n> | x | y |\n>\n> after\n"
    expect(corrected(described_class, source)).to eq(expected)
  end

  it 'uses the source buffer newline convention for CRLF input' do
    source = "before\r\n| a | b |\r\n| --- | --- |\r\nafter\r\n"
    expected = "before\r\n\r\n| a | b |\r\n| --- | --- |\r\n\r\nafter\r\n"
    expect(corrected(described_class, source)).to eq(expected.gsub("\r\n", "\n"))
  end

  it 'does not recognize table-like fenced code' do
    source = "```\nbefore\n| a | b |\n| --- | --- |\nafter\n```\n"
    expect(offenses(described_class, source)).to be_empty
  end
end
