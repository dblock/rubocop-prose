# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Prose::BareUrl do
  it 'reports bare URLs without sentence punctuation or unmatched brackets' do
    source = "Résumé https://example.test/a(b), (https://example.test/docs).\n"
    result, rewritten = investigate(described_class, source)
    expect(result.map { |offense| offense.location.source }).to eq(
      ['https://example.test/a(b)', 'https://example.test/docs']
    )
    expect(result.first.column).to eq(7)
    expect(rewritten).to eq(source)
  end

  it 'accepts links, images, autolinks, and reference destinations' do
    source = <<~MARKDOWN
      [nested [label]](https://example.test/a(b) "https://example.test/title")
      [angle](<https://example.test/with%20space>)
      ![alt](https://example.test/picture.png)
      <https://example.test> <person@example.test>
      [guide] [full][guide] ![alt][guide]

      [guide]: <https://example.test/guide>
        "https://example.test/title"
    MARKDOWN
    expect(offenses(described_class, source)).to be_empty
  end

  it 'configures schemes without checking scheme-less URLs or emails' do
    source = "https://example.test ftp://example.test www.example.test person@example.test\n"
    result = offenses(described_class, source, { 'Schemes' => ['ftp'] })
    expect(result.map { |offense| offense.location.source }).to eq(['ftp://example.test'])
    expect(offenses(described_class, source, { 'Schemes' => [] })).to be_empty
  end

  it 'excludes front matter, fenced/indented code, spans and HTML regions' do
    source = <<~'MARKDOWN'
      ---
      homepage: https://example.test
      ---

      `https://example.test` ``https://example.test/`path` ``

      ```text
      https://example.test
      ```

          https://example.test

      <!-- https://example.test -->
      <a href="https://example.test">https://example.test</a>
      <pre>https://example.test</pre>
      <div>
      https://example.test
      <div>https://example.test</div>
      </div>

      <span data-url="https://example.test">ordinary prose</span>
      https\://example.test
    MARKDOWN
    expect(offenses(described_class, source)).to be_empty
  end

  it 'still checks text following code spans and escaped link openers' do
    source = '`code` https://example.test \[label](https://example.test/path)'
    expect(offenses(described_class, source).map { |offense| offense.location.source }).to eq(
      ['https://example.test', 'https://example.test/path']
    )
  end

  it 'does not let HTML or backticks inside destinations and titles hide subsequent prose' do
    source = '[guide](docs/`path`.md "<a>") https://example.test/visible'
    expect(offenses(described_class, source).map { |offense| offense.location.source }).to eq(
      ['https://example.test/visible']
    )
  end

  it 'does not interpret reference definition titles as HTML regions' do
    source = "[guide]\n\n[guide]: docs.md \"<a>\"\n\nhttps://example.test/visible\n"
    expect(offenses(described_class, source).map { |offense| offense.location.source }).to eq(
      ['https://example.test/visible']
    )
  end
end
