# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Markdown::ThematicBreakBlankLines do
  it 'is enabled by default' do
    expect(RuboCop::Prose.default_configuration.fetch(described_class.cop_name)).to include('Enabled' => true)
  end

  it 'adds missing boundaries and is idempotent' do
    source = "***\nAfter.\n"
    expect(offenses(described_class, source).size).to eq(1)

    result = corrected(described_class, source)
    expect(result).to eq("***\n\nAfter.\n")
    expect(offenses(described_class, result)).to be_empty
  end

  it 'checks both boundaries with independent minimums' do
    source = "# Title\n***\nAfter.\n"
    result = corrected(described_class, source)

    expect(offenses(described_class, source).size).to eq(1)
    expect(result).to eq("# Title\n\n***\n\nAfter.\n")
    expect(offenses(described_class, result)).to be_empty
  end

  it 'deduplicates a shared boundary between adjacent thematic breaks' do
    source = "***\n---\n"

    expect(offenses(described_class, source).size).to eq(1)
    expect(corrected(described_class, source)).to eq("***\n\n---\n")
  end

  it 'coexists with the default maximum for consecutive blank lines' do
    source = "***\n\n\nAfter.\n"
    cops = [described_class, RuboCop::Cop::Prose::MultipleBlankLines]

    expect(corrected(cops, source)).to eq("***\n\nAfter.\n")
  end

  it 'retains blockquote and list prefixes when adding padding' do
    quote = "> ***\n> After.\n"
    item = "> - ***\n>   After.\n"

    expect(corrected(described_class, quote)).to eq("> ***\n>\n> After.\n")
    expect(corrected(described_class, item)).to eq("> - ***\n>   \n>   After.\n")
  end

  it 'preserves CRLF and Unicode source locations' do
    source = "Pr\u00e9face\r\n\r\n***\r\nAfter.\r\n"
    offense = offenses(described_class, source).first

    expect(offense.location.line).to eq(3)
    expect(corrected(described_class, source)).to eq("Pr\u00e9face\n\n***\n\nAfter.\n")
  end

  it 'does not pad document or front-matter boundaries' do
    source = "---\ntitle: Guide\n---\n***\n"

    expect(offenses(described_class, source)).to be_empty
    expect(offenses(described_class, "***\n")).to be_empty
  end

  it 'ignores Setext headings, code, and unparsed marker-looking lines' do
    source = "Title\n---\n\n```\n***\n```\n\nordinary\n***\ntext\n"

    expect(offenses(described_class, source)).to be_empty
    expect(corrected(described_class, source)).to eq(source)
  end

  it 'accepts configured counts and rejects invalid minimums' do
    source = "***\nAfter.\n"
    options = { 'LinesAbove' => 0, 'LinesBelow' => 2 }

    expect(corrected(described_class, source, options)).to eq("***\n\n\nAfter.\n")
    expect(offenses(described_class, "***\n\n\nAfter.\n", options)).to be_empty

    %w[LinesAbove LinesBelow].each do |name|
      [-1, '1'].each do |value|
        expect { offenses(described_class, source, name => value) }
          .to raise_error(RuboCop::ValidationError, /#{name} must be a nonnegative integer/)
      end

      expect do
        config = RuboCop::Config.new(
          described_class.cop_name => { name => nil }
        )
        described_class.new(config).validate_config
      end.to raise_error(RuboCop::ValidationError, /#{name} must be a nonnegative integer/)
    end
  end
end
