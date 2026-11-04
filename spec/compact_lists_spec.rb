# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Markdown::CompactLists do
  it 'is enabled by default and reports blank lines between simple sibling items' do
    expect(RuboCop::Prose.default_configuration.fetch(described_class.cop_name).fetch('Enabled')).to be(true)
    expect(offenses(described_class, "- First.\n\n- Second.\n").map(&:line)).to eq([2])
  end

  it 'removes separators between simple items and stabilizes' do
    source = "- First.\n\n\n- Second.\n\n- Third.\n"
    result = corrected(described_class, source)

    expect(result).to eq("- First.\n- Second.\n- Third.\n")
    expect(corrected(described_class, result)).to eq(result)
    expect(offenses(described_class, result)).to be_empty
  end

  it 'supports partial compactness without removing a multiple-paragraph item separator' do
    source = "- First.\n\n- Second.\n\n- First paragraph.\n\n  Second paragraph.\n\n- Last.\n"
    result = corrected(described_class, source)

    expect(offenses(described_class, source).map(&:line)).to eq([2, 4, 8])
    expect(result).to eq("- First.\n- Second.\n\n- First paragraph.\n\n  Second paragraph.\n\n- Last.\n")
    expect(corrected(described_class, result)).to eq(result)
  end

  it 'reports but does not correct separators next to nested-list and code children' do
    source = "- Parent.\n  - Nested.\n\n- Next.\n\n- Code:\n\n  ```\n  source\n  ```\n\n- Final.\n"

    expect(offenses(described_class, source).map(&:line)).to eq([3, 5, 11])
    expect(corrected(described_class, source)).to eq(source)
  end

  it 'leaves indented code report-only and autocorrects wrapped single paragraphs' do
    code = "- Code:\n\n      source\n\n- Next.\n"
    wrapped = "- First line\n  continuation\n\n- Next.\n"

    expect(offenses(described_class, code).map(&:line)).to eq([4])
    expect(corrected(described_class, code)).to eq(code)
    expect(corrected(described_class, wrapped)).to eq("- First line\n  continuation\n- Next.\n")
  end

  it 'removes quote-container separators while preserving Unicode locations' do
    source = "> - Résumé.\n>\n> - 第二.\n"

    expect(offenses(described_class, source).map(&:line)).to eq([2])
    result = corrected(described_class, source)

    expect(result).to eq("> - Résumé.\n> - 第二.\n")
    expect(corrected(described_class, result)).to eq(result)
  end

  it 'ignores blanks inside an item and compact lists' do
    source = "- First paragraph.\n\n  Second paragraph.\n- Compact.\n"

    expect(offenses(described_class, source)).to be_empty
    expect(corrected(described_class, source)).to eq(source)
  end
end
