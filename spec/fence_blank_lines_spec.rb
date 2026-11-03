# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Markdown::FenceBlankLines do
  it 'adds missing boundaries and is idempotent' do
    source = "Intro\n```ruby\nx\n```\nAfter\n"
    expect(offenses(described_class, source).size).to eq(2)
    result = corrected(described_class, source)
    expect(result).to eq("Intro\n\n```ruby\nx\n```\n\nAfter\n")
    expect(offenses(described_class, result)).to be_empty
  end

  it 'keeps list and quote containers intact' do
    source = "> - ```sh\n>   echo hi\n>   ```\n>   after\n"
    expect(corrected(described_class, source)).to eq("> - ```sh\n>   echo hi\n>   ```\n>\n>   after\n")
    expect(offenses(described_class, source, 'ListItems' => false)).to be_empty
  end

  it 'deduplicates a shared boundary between adjacent fences' do
    source = "```\na\n```\n~~~\nb\n~~~\n"
    expect(offenses(described_class, source).size).to eq(1)
    expect(corrected(described_class, source)).to eq("```\na\n```\n\n~~~\nb\n~~~\n")
  end

  it 'accepts document boundaries and ignores indented code' do
    expect(offenses(described_class, "```\nx\n```\n\n    code\n")).to be_empty
  end

  it 'allows attributes immediately below a fence without disabling padding above it' do
    source = "Intro\n```ruby\nx\n```\n{: #code}\n"
    options = { 'LinesAbove' => 2, 'LinesBelow' => 0 }
    result = corrected(described_class, source, options)

    expect(result).to eq("Intro\n\n\n```ruby\nx\n```\n{: #code}\n")
    expect(offenses(described_class, result, options)).to be_empty
  end

  it 'can enforce padding only below a fence' do
    source = "Intro\n```ruby\nx\n```\nAfter\n"
    options = { 'LinesAbove' => 0, 'LinesBelow' => 2 }
    result = corrected(described_class, source, options)

    expect(result).to eq("Intro\n```ruby\nx\n```\n\n\nAfter\n")
    expect(offenses(described_class, result, options)).to be_empty
  end

  it 'uses the larger requirement once for a shared partially padded boundary' do
    source = "```ruby\na\n```\n\n~~~sh\nb\n~~~\n"
    options = { 'LinesAbove' => 3, 'LinesBelow' => 2 }
    result = corrected(described_class, source, options)

    expect(offenses(described_class, source, options).size).to eq(1)
    expect(result).to eq("```ruby\na\n```\n\n\n\n~~~sh\nb\n~~~\n")
    expect(offenses(described_class, result, options)).to be_empty
  end

  it 'preserves nested prefixes and original Unicode locations with multiple blank lines' do
    source = "Pr\u00e9face\n\n> - ```sh\n>   echo hi\n>   ```\n>   after\n"
    options = { 'LinesAbove' => 2, 'LinesBelow' => 2 }
    result = corrected(described_class, source, options)

    expect(result).to eq("Pr\u00e9face\n\n> - ```sh\n>   echo hi\n>   ```\n>\n>\n>   after\n")
    expect(offenses(described_class, result, options)).to be_empty
  end

  it 'does not pad document boundaries or front matter to reach larger counts' do
    source = "---\ntitle: Guide\n---\n\n```ruby\nx\n```\n"

    expect(offenses(described_class, source, 'LinesAbove' => 3, 'LinesBelow' => 3)).to be_empty
  end

  it 'rejects invalid counts explicitly' do
    %w[LinesAbove LinesBelow].each do |name|
      [-1, nil, '1'].each do |value|
        expect do
          offenses(described_class, "```ruby\nx\n```\n", name => value)
        end.to raise_error(RuboCop::ValidationError, /#{name} must be a nonnegative integer/)
      end
    end
  end
end
