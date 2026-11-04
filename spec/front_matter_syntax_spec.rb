# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Markdown::FrontMatterSyntax do
  it 'is enabled by default' do
    expect(RuboCop::Prose.default_configuration.fetch('Markdown/FrontMatterSyntax')['Enabled']).to be(true)
  end

  it 'reports invalid YAML at its original Unicode-aware source location' do
    source = "---\nrésumé: [Unclosed list\n---\n\nBody.\n"
    offense = offenses(described_class, source).first

    expect([offense.location.line, offense.location.column, offense.location.source]).to eq([2, 8, '['])
    expect(offense.message).to include('Invalid YAML front matter')
  end

  it 'accepts dates and custom-tagged syntax without loading objects' do
    source = "---\ndate: 2026-11-04\nmetadata: !!ruby/object:Object {}\n---\n"

    expect(offenses(described_class, source)).to be_empty
  end

  it 'validates metadata independently of IgnoreFrontMatter' do
    source = "---\ntitle: [Unclosed list\n---\n"
    enabled = { settings: { 'Markdown' => { 'IgnoreFrontMatter' => true } } }
    disabled = { settings: { 'Markdown' => { 'IgnoreFrontMatter' => false } } }

    expect(offenses(described_class, source, **enabled).map(&:line)).to eq([2])
    expect(offenses(described_class, source, **disabled).map(&:line)).to eq([2])
  end

  it 'only checks closed leading front matter' do
    ["---\ntitle: [Unclosed list\n", "Text.\n\n---\ntitle: [Unclosed list\n---\n"].each do |source|
      expect(offenses(described_class, source)).to be_empty
    end
  end
end
