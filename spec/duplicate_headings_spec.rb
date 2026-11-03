# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Prose::DuplicateHeadings do
  it 'reports repeated plain text in document scope' do
    expect(offenses(described_class, "# Résumé\n\n## *Résumé*\n").map(&:line)).to eq([3])
  end

  it 'allows different case and distinct text' do
    expect(offenses(described_class, "# Title\n\n## title\n\n## Other\n")).to be_empty
  end

  it 'allows the same child under distinct parents in sibling scope' do
    source = "# First\n\n## Usage\n\n# Second\n\n## Usage\n"
    expect(offenses(described_class, source, { 'Scope' => 'siblings' })).to be_empty
    expect(offenses(described_class, source).size).to eq(1)
  end

  it 'reports siblings even when their heading levels skip' do
    source = "# Parent\n\n### Child\n\n## Child\n"
    expect(offenses(described_class, source, { 'Scope' => 'siblings' }).size).to eq(1)
  end

  it 'starts a new child scope for each parent occurrence' do
    source = "# Same\n\n## Usage\n\n# Same\n\n## Usage\n"
    expect(offenses(described_class, source, { 'Scope' => 'siblings' }).map(&:line)).to eq([5])
  end

  it 'includes Setext headings but excludes code and front matter' do
    source = "---\ntitle: Title\n---\nTitle\n=====\n\n```\n# Title\n```\n\n    # Title\n\n\\# Title\n"
    expect(offenses(described_class, source)).to be_empty
    expect(offenses(described_class, "Title\n=====\n\n## Title\n").size).to eq(1)
  end

  it 'does not rename duplicates' do
    source = "# Title\n\n## Title\n"
    expect(corrected(described_class, source)).to eq(source)
  end
end
