# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Markdown::OutsideSpacing do
  it 'reports adjacent code and emphasis boundaries without correcting them' do
    source = "Use`command`now; read**important**text.\n"

    expect(offenses(described_class, source).size).to eq(2)
    expect(corrected(described_class, source)).to eq(source)
  end

  it 'uses original Unicode character locations' do
    source = "Éclair`command`now.\n"

    offense = offenses(described_class, source).first

    expect(offense.location.line).to eq(1)
    expect(offense.location.column).to eq(6)
    expect(offense.location.length).to eq('`command`'.length)
  end

  it 'ignores spacing, punctuation-only boundaries, and scripts without space-delimited words' do
    source = "Use `command` now; read **important** text.\nAPI:`command`。你好**重要**文本。\n"

    expect(offenses(described_class, source)).to be_empty
  end

  it 'preserves potentially intentional intraword formatting without autocorrection' do
    source = "pre*fix*ed and a`b`c\n"

    expect(offenses(described_class, source).size).to eq(2)
    expect(corrected(described_class, source)).to eq(source)
  end

  it 'does not report protected inline constructs or multiline spans' do
    source = "[word`code`word](url) <b>word**text**word</b> \\*literal* `code\nspan` *multi\nline*\n"

    expect(offenses(described_class, source)).to be_empty
  end

  it 'is enabled in the default configuration' do
    expect(RuboCop::Prose.default_configuration.fetch('Markdown/OutsideSpacing').fetch('Enabled')).to be(true)
  end
end
