# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Markdown::Syntax do
  it 'reports native parser diagnostics at original locations after front matter' do
    source = "---\ntitle: metadata\n---\n\nText [label][missing].\n"
    result = offenses(described_class, source)
    expect(result.length).to eq(1)
    expect(result.first.line).to eq(5)
    expect(result.first.message).to include("No link definition for link ID 'missing'")
  end

  it 'keeps duplicate-definition diagnostics within the original buffer' do
    result = offenses(described_class, "[x]: /one\n[x]: /two\n")
    expect(result.first.line).to eq(2)
    expect(result.first.message).to include('Duplicate link ID')
  end

  it 'does not diagnose valid references or rewrite invalid references' do
    expect(offenses(described_class, "[label][id]\n\n[id]: /target\n")).to be_empty
    source = "[label][missing]\n"
    expect(corrected(described_class, source)).to eq(source)
  end
end
