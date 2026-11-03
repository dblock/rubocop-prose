# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Prose::ReversedLink do
  it 'reports reversed delimiters at their original Unicode source positions' do
    source = "Résumé (API reference)[https://example.test/api]\n"
    result, rewritten = investigate(described_class, source)
    expect(result.map { |offense| offense.location.source }).to eq(['(API reference)[https://example.test/api]'])
    expect(result.first.column).to eq(7)
    expect(rewritten).to eq(source)
  end

  it 'recognizes nested parentheses without confusing valid links' do
    source = "(API (v2))[./api.md] and [API (v2)](./api.md)\n"
    expect(offenses(described_class, source).map { |offense| offense.location.source }).to eq(['(API (v2))[./api.md]'])
  end

  it 'accepts ordinary parenthetical prose followed by a resolved reference' do
    source = "(read this) [guide] and (see)[guide]\n\n[guide]: guide.md\n"
    expect(offenses(described_class, source)).to be_empty
  end

  it 'excludes code, front matter, escaped syntax, HTML and autolinks' do
    source = <<~'MARKDOWN'
      ---
      title: (text)[url]
      ---

      `(text)[url]` and ``(text)[url] ` tick``

      ~~~
      (text)[url]
      ~~~

          (text)[url]

      \(text)[url]
      <!-- (text)[url] -->
      <code>(text)[url]</code>
      <https://example.test/(text)[url]>
    MARKDOWN
    expect(offenses(described_class, source)).to be_empty
  end

  it 'does not scan across blank paragraphs or escaped closing delimiters' do
    source = "(unfinished\n\ntext)[url]\n\n(text)[url\\]]\n"
    expect(offenses(described_class, source).map { |offense| offense.location.source }).to eq(['(text)[url\\]]'])
  end
end
