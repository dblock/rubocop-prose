# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Markdown::FenceBlankLines do
  it 'adds missing boundaries and is idempotent' do
    source = "Intro\n```ruby\nx\n```\nAfter\n"
    expect(offenses(described_class, source).size).to eq(2)
    result = corrected(described_class, source)
    expect(result).to eq("Intro\n\n```ruby\nx\n```\n\nAfter\n")
    expect(offenses(described_class, result)).to be_empty
  end

  it 'keeps list and quote containers intact' do
    source = "> - ```sh\n>   echo hi\n>   ```\n>   after\n"
    expect(corrected(described_class, source)).to eq("> - ```sh\n>   echo hi\n>   ```\n>\n>   after\n")
    expect(offenses(described_class, source, 'ListItems' => false)).to be_empty
  end

  it 'deduplicates a shared boundary between adjacent fences' do
    source = "```\na\n```\n~~~\nb\n~~~\n"
    expect(offenses(described_class, source).size).to eq(1)
    expect(corrected(described_class, source)).to eq("```\na\n```\n\n~~~\nb\n~~~\n")
  end

  it 'accepts document boundaries and ignores indented code' do
    expect(offenses(described_class, "```\nx\n```\n\n    code\n")).to be_empty
  end
end
