# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Prose::EmphasisHeading do
  it 'reports single-line strong and emphasis-only paragraphs' do
    expect(offenses(described_class, "**Overview**\n\n_Usage_\n").map(&:line)).to eq([1, 3])
  end

  it 'allows real headings and mixed prose' do
    expect(offenses(described_class, "# **Overview**\n\nSome **important** text.\n")).to be_empty
  end

  it 'allows multiline emphasis and escaped markers' do
    expect(offenses(described_class, "**Long\nparagraph**\n\n\\*Literal\\*\n")).to be_empty
  end

  it 'includes container paragraphs and punctuation' do
    expect(offenses(described_class, "> **Overview.**\n\n- *Usage*\n").size).to eq(2)
  end

  it 'excludes code and front matter' do
    source = "---\ntitle: '**Overview**'\n---\n```\n**Code**\n```\n\n    *Code*\n"
    expect(offenses(described_class, source)).to be_empty
  end

  it 'does not guess a heading level' do
    expect(corrected(described_class, "**Overview**\n")).to eq("**Overview**\n")
  end
end
