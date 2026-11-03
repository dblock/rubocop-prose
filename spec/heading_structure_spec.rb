# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Markdown::HeadingStructure do
  let(:options) { { 'Headings' => ['# Title', '## Usage'] } }

  it 'reports incorrect levels, names and unexpected headings' do
    result = offenses(described_class, "# Title\n\n### Wrong\n\n## Extra\n", options)
    expect(result.map(&:line)).to eq([3, 5])
  end

  it 'accepts an exact outline with either heading syntax' do
    expect(offenses(described_class, "Title\n=====\n\nUsage\n-----\n", options)).to be_empty
  end

  it 'compares rendered inline text and Unicode literally' do
    config = { 'Headings' => ['# Résumé', '## Usage'] }
    expect(offenses(described_class, "# *Résumé*\n\n## `Usage`\n", config)).to be_empty
  end

  it 'reports a missing suffix at end of file' do
    result = offenses(described_class, "# Title\n", options)
    expect(result.size).to eq(1)
    expect(result.first.message).to include('missing')
  end

  it 'reports missing headings in an empty document without raising' do
    expect(offenses(described_class, '', options).size).to eq(1)
  end

  it 'ignores code and front matter' do
    source = "---\ntitle: Other\n---\n# Title\n\n```\n# Other\n```\n\n    ## Code\n\n## Usage\n"
    expect(offenses(described_class, source, options)).to be_empty
  end

  it 'does nothing without a configured outline' do
    expect(offenses(described_class, "# Any\n\n### Structure\n")).to be_empty
  end

  it 'rejects unsupported outline syntax explicitly' do
    expect { offenses(described_class, "# Title\n", { 'Headings' => ['*'] }) }.to raise_error(ArgumentError, /ATX outline/)
  end

  it 'does not reorder or generate headings' do
    source = "# Wrong\n"
    expect(corrected(described_class, source, options)).to eq(source)
  end
end
