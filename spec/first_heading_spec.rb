# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Markdown::FirstHeading do
  it 'reports prose before the first heading and a wrong level' do
    expect(offenses(described_class, "Preamble\n\n# Title\n").map(&:line)).to eq([1])
    expect(offenses(described_class, "## Title\n").size).to eq(1)
  end

  it 'accepts ATX, Setext and configured heading levels' do
    expect(offenses(described_class, "\n# Title\n")).to be_empty
    expect(offenses(described_class, "Title\n=====\n")).to be_empty
    expect(offenses(described_class, "## Title\n", { 'Level' => 2 })).to be_empty
  end

  it 'accepts a configured front-matter title' do
    source = "---\nname: |\n  A document\n---\nPreamble\n"
    expect(offenses(described_class, source, { 'TitleKey' => 'name' })).to be_empty
    expect(offenses(described_class, "---\ntitle: Title\n---\nText\n")).to be_empty
  end

  it 'can disable the front-matter title exemption' do
    source = "---\ntitle: Title\n---\nText\n"
    expect(offenses(described_class, source, { 'FrontMatterTitle' => false }).map(&:line)).to eq([4])
  end

  it 'rejects missing, non-string, blank and invalid titles without raising' do
    ['other: Title', 'title: 42', "title: ''", 'title: [broken', "title: &name Hello\nother: *name"].each do |yaml|
      expect(offenses(described_class, "---\n#{yaml}\n---\nText\n").size).to eq(1)
    end
  end

  it 'does not mistake code or escaped markers for a first heading' do
    expect(offenses(described_class, "```\n# Code\n```\n\n# Title\n").map(&:line)).to eq([1])
    expect(offenses(described_class, "\\# Literal\n").size).to eq(1)
  end

  it 'accepts empty and front-matter-only documents' do
    expect(offenses(described_class, '')).to be_empty
    expect(offenses(described_class, "---\nother: Value\n---\n")).to be_empty
  end

  it 'does not insert or move titles' do
    expect(corrected(described_class, "Preamble\n")).to eq("Preamble\n")
  end
end
