# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Markdown::DuplicateHeadings do
  it 'reports repeated plain text in document scope' do
    expect(offenses(described_class, "# Résumé\n\n## *Résumé*\n", 'Scope' => 'document').map(&:line)).to eq([3])
  end

  it 'allows different case and distinct text' do
    expect(offenses(described_class, "# Title\n\n## title\n\n## Other\n")).to be_empty
  end

  it 'allows the same child under distinct parents by default' do
    source = "# First\n\n## Usage\n\n# Second\n\n## Usage\n"
    expect(offenses(described_class, source)).to be_empty
    expect(offenses(described_class, source, { 'Scope' => 'document' }).size).to eq(1)
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
    expect(offenses(described_class, "Title\n=====\n\n## Title\n", 'Scope' => 'document').size).to eq(1)
  end

  it 'does not rename duplicates' do
    source = "# Title\n\n## Title\n"
    expect(corrected(described_class, source)).to eq(source)
  end

  it 'combines document-wide higher headings with sibling-scoped deeper headings' do
    source = "# Guide\n\n## Services\n\n### Overview\n\n#### Details\n\n## Clients\n\n### Overview\n\n#### Details\n\n#### Details\n"
    options = { 'Scope' => { 'Default' => 'document', 4 => 'siblings' } }
    expect(offenses(described_class, source, options).map(&:line)).to eq([11, 15])
    expect(corrected(described_class, source, options)).to eq(source)
  end

  it 'uses the default scope for unlisted levels and compares against earlier headings of other scopes' do
    source = "# Title\n\n## *Title*\n\n### `Title`\n"
    options = { 'Scope' => { 'Default' => 'siblings', 2 => 'document' } }
    expect(offenses(described_class, source, options).map(&:line)).to eq([3])
    options = { 'Scope' => { 'Default' => 'document', 2 => 'siblings' } }
    expect(offenses(described_class, source, options).map(&:line)).to eq([5])
  end

  it 'retains skipped-level siblings and parent occurrence identity with overrides' do
    source = "# Parent\n\n### Child\n\n## Child\n\n# Parent\n\n### Child\n"
    options = { 'Scope' => { 'Default' => 'siblings', 2 => 'siblings', 3 => 'siblings' } }
    expect(offenses(described_class, source, options).map(&:line)).to eq([5, 7])
  end

  it 'applies level overrides to Setext headings without normalizing case or whitespace' do
    source = "Résumé\n======\n\n*Résumé*\n------\n\n## résumé\n\n## Résumé \n"
    options = { 'Scope' => { 'Default' => 'siblings', 2 => 'document' } }
    expect(offenses(described_class, source, options).map(&:line)).to eq([4, 9])
  end

  it 'validates level mappings and scope names' do
    [
      'unknown', nil, [], {}, { 4 => 'siblings' }, { 'Default' => 'unknown' },
      { 'Default' => 'siblings', 0 => 'siblings' }, { 'Default' => 'siblings', 7 => 'document' },
      { 'Default' => 'siblings', '4' => 'siblings' }, { 'Default' => 'siblings', 4 => 'unknown' }
    ].each do |options|
      expect { offenses(described_class, "# Title\n", 'Scope' => options) }.to raise_error(RuboCop::ValidationError)
    end
  end

  it 'disables levels without discarding ancestry or comparison history' do
    source = "# Parent\n\n## Same\n\n## Same\n\n### Child\n\n### Child\n\n# Same\n"
    options = { 'Scope' => { 'Default' => 'document', 2 => false, 3 => 'siblings' } }
    expect(offenses(described_class, source, options).map(&:line)).to eq([9, 11])
    expect(offenses(described_class, source, 'Scope' => false)).to be_empty
  end

  it 'supports inclusive ranges and strict comparisons' do
    source = "# Parent\n\n## Same\n\n## Same\n\n#### Deep\n\n#### Deep\n\n##### Deeper\n\n##### Deeper\n"
    range = { 'Scope' => { 'Default' => 'document', '4-6' => false } }
    comparison = { 'Scope' => { 'Default' => 'document', '>3' => false } }
    expect(offenses(described_class, source, range).map(&:line)).to eq([5])
    expect(offenses(described_class, source, comparison).map(&:line)).to eq([5])
    expect(offenses(described_class, source, 'Scope' => { 'Default' => false, '<3' => 'document' }).map(&:line))
      .to eq([5])
  end

  it 'rejects malformed, empty, and overlapping selectors' do
    [
      { '4-6' => false, 5 => 'siblings' }, { '>3' => false, '5-6' => false },
      { '6-4' => false }, { '>6' => false }, { '<1' => false },
      { '0-3' => false }, { '>=4' => false }, { '4' => false }
    ].each do |selectors|
      expect do
        offenses(described_class, "# Title\n", 'Scope' => { 'Default' => 'document' }.merge(selectors))
      end.to raise_error(RuboCop::ValidationError)
    end
  end
end
