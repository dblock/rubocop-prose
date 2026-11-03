# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Markdown::HeadingPunctuation do
  it 'reports trailing punctuation through inline formatting' do
    expect(offenses(described_class, "## *Title!* ##\n").size).to eq(1)
  end

  it 'allows internal punctuation and unpunctuated headings' do
    expect(offenses(described_class, "# What? This\n\n## Title\n")).to be_empty
  end

  it 'supports literal Unicode punctuation' do
    options = { 'Punctuation' => '。！' }
    expect(offenses(described_class, "# 題名。\n", options).size).to eq(1)
    expect(offenses(described_class, "# Title!\n", options)).to be_empty
  end

  it 'supports an empty punctuation set' do
    expect(offenses(described_class, "# Title!\n", { 'Punctuation' => '' })).to be_empty
  end

  it 'checks rendered escaped punctuation and Setext headings' do
    expect(offenses(described_class, "# Title\\!\n\nOther?\n------\n").size).to eq(2)
  end

  it 'ignores code and preserves meaningful punctuation' do
    expect(offenses(described_class, "```\n# Code!\n```\n")).to be_empty
    expect(corrected(described_class, "# Title!\n")).to eq("# Title!\n")
  end
end
