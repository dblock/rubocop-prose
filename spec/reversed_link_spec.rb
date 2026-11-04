# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Markdown::ReversedLink do
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

  it 'accepts single citation keys with optional author suppression' do
    source = <<~MARKDOWN
      (abbrev)[@citekey] and (abbrev)[-@R-base]
      (abbrev)[@a] and (abbrev)[-@1]
      (abbrev)[@doe:2024.test_2] and (abbrev)[-@cafe\u0301-2024]
      (abbrev)[@研究2024] and (abbrev)[@doe/2024+edition]
    MARKDOWN
    result, rewritten = investigate(described_class, source)
    expect(result).to be_empty
    expect(rewritten).to eq(source)
  end

  it 'still reports reversed links and destinations that are not complete citation keys' do
    source = <<~'MARKDOWN'
      Résumé (guide)[./guide.md] and (section)[#citekey]
      (empty)[@] and (suppressed)[-@]
      (path)[@/guide] and (punctuation)[@key?]
      (escaped)[\@citekey] and (entity)[&#64;citekey]
    MARKDOWN
    result, rewritten = investigate(described_class, source)
    expect(result.map { |offense| offense.location.source }).to eq(
      ['(guide)[./guide.md]', '(section)[#citekey]', '(empty)[@]', '(suppressed)[-@]',
       '(path)[@/guide]', '(punctuation)[@key?]', '(escaped)[\@citekey]', '(entity)[&#64;citekey]']
    )
    expect(result.first.column).to eq(7)
    expect(rewritten).to eq(source)
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
