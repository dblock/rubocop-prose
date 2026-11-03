# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Prose::HeadingIndentation do
  it 'reports indented ATX headings' do
    expect(offenses(described_class, "  ## Title\n").size).to eq(1)
  end

  it 'reports an indented Setext title' do
    expect(offenses(described_class, "  Title\n  =====\n").size).to eq(1)
  end

  it 'allows unindented headings and blockquote prefixes' do
    expect(offenses(described_class, "# Title\n\n> ## Detail\n")).to be_empty
  end

  it 'ignores indented code, fenced code and escaped markers' do
    source = "    # Code\n\n```\n  # Code\n```\n\n  \\# Literal\n"
    expect(offenses(described_class, source)).to be_empty
  end

  it 'does not move headings out of containers' do
    expect(corrected(described_class, "  # Title\n")).to eq("  # Title\n")
  end
end
