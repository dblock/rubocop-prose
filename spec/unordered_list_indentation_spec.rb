# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Markdown::UnorderedListIndentation do
  it 'reports a nested list with the wrong width without unsafe correction' do
    source = "- parent\n    - child\n"
    expect(offenses(described_class, source).size).to eq(1)
    expect(corrected(described_class, source)).to eq(source)
  end

  it 'accepts configured indentation inside quotes' do
    expect(offenses(described_class, "> - parent\n>     - child\n", 'Indent' => 4)).to be_empty
  end

  it 'does not check ordered items or code' do
    expect(offenses(described_class, "  1. ordered\n\n```\n   - example\n```\n")).to be_empty
  end

  it 'starts a fresh indentation baseline inside a nested quote container' do
    expect(offenses(described_class, "- parent\n  > - child\n")).to be_empty
    expect(offenses(described_class, "- > - child\n")).to be_empty
  end

  it 'accepts unordered children aligned with ordered parent content' do
    expect(offenses(described_class, "1. item\n\n   - child\n")).to be_empty
    expect(offenses(described_class, "10. item\n\n    - child\n")).to be_empty
    expect(offenses(described_class, "100) item\n\n     - child\n")).to be_empty
    expect(offenses(described_class, "1.   item\n\n     - child\n")).to be_empty
  end

  it 'retains the configured offset when it exceeds the ordered content width' do
    source = "1. item\n\n    - child\n        - grandchild\n"
    expect(offenses(described_class, source, 'Indent' => 4)).to be_empty
    offense = offenses(described_class, "1. item\n\n   - child\n", 'Indent' => 4).fetch(0)
    expect(offense.message).to end_with('Use 4 spaces of unordered list indentation.')
  end

  it 'preserves configured unordered parent indentation despite wider marker spacing' do
    source = "-   item\n\n    - child\n"
    expect(offenses(described_class, source, 'Indent' => 4)).to be_empty
    offense = offenses(described_class, source).fetch(0)
    expect(offense.message).to end_with('Use 2 spaces of unordered list indentation.')
  end

  it 'handles mixed inline items and blockquote baselines' do
    expect(offenses(described_class, "1. - child\n     - grandchild\n")).to be_empty
    expect(offenses(described_class, "- 10. - child\n        - grandchild\n")).to be_empty
    expect(offenses(described_class, "> 10. item\n>\n>     - child\n")).to be_empty
    expect(offenses(described_class, "10. item\n\n    > - child\n")).to be_empty
    expect(offenses(described_class, "10. > - child\n")).to be_empty
  end

  it 'reports mixed-list indentation at original Unicode ranges without rewriting the subtree' do
    source = "Résumé 🌍\n\n> 10. café\n>\n>       - child\n>         continuation\n"
    found, result = investigate(described_class, source)
    expect(found.size).to eq(1)
    offense = found.fetch(0)
    expect(offense.message).to end_with('Use 4 spaces of unordered list indentation.')
    expect(offense.location.line).to eq(5)
    expect(offense.location.column).to eq(8)
    expect(offense.location.begin_pos).to eq(source.index('- child'))
    expect(offense.location.source).to eq('-')
    expect(result).to eq(source)
    expect(corrected(described_class, result)).to eq(source)
  end
end
