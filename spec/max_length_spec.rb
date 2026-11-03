# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Prose::MaxLength do
  it 'wraps at the configured width and stabilizes' do
    result = corrected(described_class, "One two three four five.\n", 'Max' => 13)
    expect(result).to eq("One two three\nfour five.\n")
    expect(corrected(described_class, result, 'Max' => 13)).to eq(result)
  end

  it 'preserves Unicode and nested blockquote prefixes' do
    source = "> Hello \u{1f600} world again.\n"
    expect(corrected(described_class, source, 'Max' => 15)).to eq("> Hello \u{1f600} world\n> again.\n")
    expect(offenses(described_class, source, 'Max' => 15).first.line).to eq(1)
  end

  it 'does not split code, links, or introduce a Markdown block' do
    source = "Words `a b c` and [link text](https://example.com).\n"
    result = corrected(described_class, source, 'Max' => 12)
    expect(result).to include('`a b c`', '[link text](https://example.com)')
    expect(corrected(described_class, "Some words - not a list.\n", 'Max' => 10)).not_to include("\n- ")
  end

  it 'leaves fenced code and front matter unchanged' do
    source = "---\ntitle: long metadata unchanged\n---\n\n~~~ruby\nputs 'very long code'\n~~~\n"
    expect(offenses(described_class, source, 'Max' => 5)).to be_empty
  end

  it 'honors native hidden suppression directives' do
    source = "<!-- # rubocop:disable Prose/MaxLength -->\nLong text stays unchanged.\n"
    expect(corrected(described_class, source, 'Max' => 10)).to eq(source)
    expect(offenses(described_class, source, 'Max' => 10)).to be_empty
  end

  it 'does not inspect ordinary Ruby files' do
    expect(offenses(described_class, "# Very long Ruby comment.\n", { 'Max' => 5 }, path: 'test.rb')).to be_empty
  end

  it 'offers relaxed or strict URL-only line reporting' do
    source = "https://example.com/a-long-address\n"
    expect(offenses(described_class, source, 'Max' => 10)).to be_empty
    expect(offenses(described_class, source, 'Max' => 10, 'IgnoreURLs' => false).length).to eq(1)
  end
end
