# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Prose::CodeSpanSpacing do
  it 'removes redundant symmetric single-space padding without changing backticks' do
    source = "Text ` foo ` and `` bar ``.\n"
    expected = "Text `foo` and ``bar``.\n"
    expect(offenses(described_class, source).size).to eq(2)
    expect(corrected(described_class, source)).to eq(expected)
    expect(offenses(described_class, expected)).to be_empty
  end

  it 'preserves padding required for literal edge backticks and all-space values' do
    source = "Text `` `foo` `` and `` foo` `` and `   `.\n"
    expect(offenses(described_class, source)).to be_empty
  end

  it 'reports but does not change whitespace that is part of the code value' do
    source = "Text `` foo`` and ``  foo  ``.\n"
    expect(offenses(described_class, source).size).to eq(2)
    expect(corrected(described_class, source)).to eq(source)
  end

  it 'ignores fenced code, links, HTML, and escaped backticks' do
    source = "[` foo `](url) <b>` foo `</b> \\` foo \\`\n\n```\n` foo `\n```\n"
    expect(offenses(described_class, source)).to be_empty
  end

  it 'reports multiline padding without rewriting the code value' do
    source = "Text `` foo\nbar ``.\n"
    expect(offenses(described_class, source).size).to eq(1)
    expect(corrected(described_class, source)).to eq(source)
  end
end
