# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Markdown::ListBlankLines do
  it 'adds a blank before a list following a paragraph' do
    source = "Introduction\n- item\n"
    expect(offenses(described_class, source).size).to eq(1)
    result = corrected(described_class, source)
    expect(result).to eq("Introduction\n\n- item\n")
    expect(offenses(described_class, result)).to be_empty
  end

  it 'adds a blank after a list before an HTML block' do
    expect(corrected(described_class, "- item\n<div>Next</div>\n")).to eq("- item\n\n<div>Next</div>\n")
  end

  it 'preserves quote containers' do
    expect(corrected(described_class, "> Intro\n> - item\n")).to eq("> Intro\n>\n> - item\n")
  end

  it 'does not separate parents from nested lists or inspect code' do
    expect(offenses(described_class, "- parent\n  - child\n\n```\ntext\n- code\n```\n")).to be_empty
  end
end
