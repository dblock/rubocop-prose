# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Markdown::FrontMatterKeys do
  it 'reports unknown keys at their Unicode source locations and missing keys at the header' do
    source = "---\n{title: Hello, étiquette: Ruby}\n---\n"
    options = { 'AllowedKeys' => %w[title date], 'RequiredKeys' => ['date'] }
    found = offenses(described_class, source, options)
    expect(found.map { |offense| [offense.line, offense.column, offense.location.source] }).to eq(
      [[2, 15, 'étiquette'], [1, 0, '---']]
    )
    expect(corrected(described_class, source, options)).to eq(source)
  end

  it 'checks decoded case-sensitive scalar names without inspecting nested keys or tagged values' do
    source = "---\n\"title\": !ruby/object:NeverInstantiate {}\nmetadata:\n  unknown: true\nTitle: Other\n---\n"
    options = { 'AllowedKeys' => %w[title metadata], 'RequiredKeys' => ['title'] }
    expect(offenses(described_class, source, options).map { |offense| offense.location.source }).to eq(['Title'])
  end

  it 'allows unrestricted keys by default and supports an empty allowlist' do
    source = "---\ntitle:\n---\n"
    expect(offenses(described_class, source)).to be_empty
    expect(offenses(described_class, source, 'AllowedKeys' => []).size).to eq(1)
    expect(offenses(described_class, source, 'RequiredKeys' => ['title'])).to be_empty
  end

  it 'checks empty headers but does not require front matter to exist' do
    options = { 'RequiredKeys' => ['title'] }
    expect(offenses(described_class, "---\n---\n", options).size).to eq(1)
    expect(offenses(described_class, "# Heading\n", options)).to be_empty
  end

  it 'skips malformed YAML and unclosed headers' do
    expect(offenses(described_class, "---\ntitle: [broken\n---\n")).to be_empty
    expect(offenses(described_class, "---\ntitle: Example\n", 'RequiredKeys' => ['date'])).to be_empty
  end

  it 'reports non-mapping front matter and complex keys' do
    expect(offenses(described_class, "---\n- title\n---\n").first.message).to include('must be a mapping')
    source = "---\n? [title, date]\n: value\n---\n"
    expect(offenses(described_class, source).first.message).to include('must be scalar')
  end

  it 'does not expand YAML merge keys or aliases' do
    source = "---\ndefaults: &defaults\n  title: Example\n<<: *defaults\n---\n"
    options = { 'AllowedKeys' => %w[defaults title], 'RequiredKeys' => ['title'] }
    found = offenses(described_class, source, options)
    expect(found.first.message).to include('Front matter key `<<` is not allowed.')
    expect(found.last.message).to include('Missing required front matter key `title`.')
  end

  it 'checks ignored front matter but never plain text or later fenced YAML' do
    source = "---\nextra: true\n---\n"
    options = { 'AllowedKeys' => [] }
    expect(offenses(described_class, source, options, settings: { 'Markdown' => { 'IgnoreFrontMatter' => true } }).size).to eq(1)
    expect(offenses(described_class, source, options, path: 'example.txt')).to be_empty
    expect(offenses(described_class, "# Heading\n\n```yaml\nextra: true\n```\n", options)).to be_empty
  end

  it 'rejects malformed or contradictory key settings' do
    [
      { 'AllowedKeys' => 'title' }, { 'RequiredKeys' => [nil] },
      { 'AllowedKeys' => [], 'RequiredKeys' => ['title'] }
    ].each do |options|
      expect { offenses(described_class, "---\n---\n", options) }.to raise_error(RuboCop::ValidationError)
    end
  end
end
