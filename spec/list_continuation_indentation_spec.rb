# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Markdown::ListContinuationIndentation do
  it 'reports lazy continuation text without rewriting it' do
    source = "- item\ncontinued text\n"

    offense = offenses(described_class, source).fetch(0)

    expect([offense.line, offense.column, offense.location.source]).to eq([2, 0, 'c'])
    expect(corrected(described_class, source)).to eq(source)
  end

  it 'uses ordered marker widths and preserves Unicode source locations' do
    source = "12. Résumé\n   続き\n"

    offense = offenses(described_class, source).fetch(0)

    expect([offense.line, offense.column, offense.location.source]).to eq([2, 3, '続'])
  end

  it 'accounts for quote prefixes and nested mixed lists' do
    quoted = "> - item\n> lazy\n"
    nested = "- parent\n  12. inner\n  lazy\n"

    expect(offenses(described_class, quoted).map(&:column)).to eq([2])
    expect(offenses(described_class, nested).map(&:line)).to eq([3])
  end

  it 'maps continuation lines after nested inline syntax' do
    offense = offenses(described_class, "- [a **nested** link](url)\ncontinued\n").fetch(0)

    expect([offense.line, offense.location.source]).to eq([2, 'c'])
  end

  it 'accepts aligned continuations and ignores following paragraphs and child blocks' do
    source = <<~MARKDOWN
      - item
        aligned text

      Outside the list.

      - code

        ```text
        preserved
        ```

      - nested
        - child
          child continuation
    MARKDOWN

    expect(offenses(described_class, source)).to be_empty
  end

  it 'is enabled by default' do
    settings = RuboCop::Prose.default_configuration.fetch(described_class.cop_name)

    expect(settings.fetch('Enabled')).to be(true)
  end
end
