# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Markdown::CodeBlockStyle do
  it 'uses the first parsed code style in consistent mode' do
    source = "```\none\n```\n\n    two\n"
    expect(offenses(described_class, source).size).to eq(1)
    result = corrected(described_class, source)
    expect(result).to eq("```\none\n```\n\n```\ntwo\n```\n")
    expect(offenses(described_class, result)).to be_empty
  end

  it 'converts standalone unlabeled fences into indented blocks' do
    source = "```\nx\n```\n"
    result = corrected(described_class, source, 'EnforcedStyle' => 'indented')
    expect(result).to eq("    x\n")
    expect(offenses(described_class, result, 'EnforcedStyle' => 'indented')).to be_empty
  end

  it 'uses a fence longer than backticks in indented content' do
    expect(corrected(described_class, "    ```\n", 'EnforcedStyle' => 'fenced')).to eq("````\n```\n````\n")
  end

  it 'reports unsafe conversions without losing metadata or containers' do
    ["```ruby\nx\n```\n", "> ```\n> x\n> ```\n", "- ```\n  x\n  ```\n", "Intro\n```\nx\n```\n"].each do |source|
      expect(offenses(described_class, source, 'EnforcedStyle' => 'indented').size).to eq(1)
      expect(corrected(described_class, source, 'EnforcedStyle' => 'indented')).to eq(source)
    end
  end

  it 'ignores code-shaped front matter' do
    expect(offenses(described_class, "---\n    value: x\n---\n", 'EnforcedStyle' => 'fenced')).to be_empty
  end

  it 'does not merge separate code blocks when changing to indentation' do
    source = "    first\n\n```\nsecond\n```\n"
    expect(offenses(described_class, source, 'EnforcedStyle' => 'indented').size).to eq(1)
    expect(corrected(described_class, source, 'EnforcedStyle' => 'indented')).to eq(source)
  end

  it 'does not merge two fences converted during the same investigation' do
    source = "```\nfirst\n```\n\n```\nsecond\n```\n"
    expect(offenses(described_class, source, 'EnforcedStyle' => 'indented').size).to eq(2)
    expect(corrected(described_class, source, 'EnforcedStyle' => 'indented')).to eq(source)
  end
end
