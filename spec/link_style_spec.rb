# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Markdown::LinkStyle do
  it 'accepts every supported style by default' do
    source = "[inline](page.md) <https://example.test> <person@example.test> [full][id] [id][] [id] ![alt](img.svg)\n\n[id]: page.md\n"
    expect(offenses(described_class, source)).to be_empty
  end

  it 'configures links independently from images and checks nested images' do
    source = "[inline](page.md) [![](img.svg)](page.md) ![alt][image]\n\n[image]: img.svg\n"
    options = { 'AllowedLinkStyles' => ['reference'], 'AllowedImageStyles' => ['inline'] }
    result, rewritten = investigate(described_class, source, options)
    expect(result.map { |offense| offense.location.source }).to eq(
      ['[inline](page.md)', '[![](img.svg)](page.md)', '![alt][image]']
    )
    expect(rewritten).to eq(source)
  end

  it 'can select individual reference forms and angle autolinks' do
    source = "[full][id] [id][] [ID] <https://example.test> <person@example.test>\n\n[id]: page.md\n"
    options = { 'AllowedLinkStyles' => ['full_reference'] }
    expect(offenses(described_class, source, options).map { |offense| offense.location.source }).to eq(
      ['[id][]', '[ID]', '<https://example.test>', '<person@example.test>']
    )
  end

  it 'does not interpret angle-delimited destinations or titles as autolinks' do
    source = '[guide](<https://example.test> "<https://example.test/title>")'
    expect(offenses(described_class, source, { 'AllowedLinkStyles' => ['inline'] })).to be_empty
  end

  it 'recognizes inner links instead of an invalid enclosing nested link' do
    source = '[outer [inner](inner.md)](outer.md)'
    result = offenses(described_class, source, { 'AllowedLinkStyles' => [] })
    expect(result.map { |offense| offense.location.source }).to eq(['[inner](inner.md)'])
  end

  it 'retains Unicode ranges while skipping prose, escaped syntax and masked spans' do
    source = '😀 café \\[escaped](skip) `[code](skip)` <!-- [hidden](skip) --> [résumé](guide.md)![图](image.svg)<https://example.test>'
    result, rewritten = investigate(described_class, source,
                                    { 'AllowedLinkStyles' => [], 'AllowedImageStyles' => [] })
    expect(result.map { |offense| offense.location.source }).to eq(
      ['[résumé](guide.md)', '![图](image.svg)', '<https://example.test>']
    )
    expect(result.map { |offense| offense.location.begin_pos }).to eq(
      ['[résumé]', '![图]', '<https:'].map { |text| source.index(text) }
    )
    expect(rewritten).to eq(source)
  end

  it 'leaves unresolved references and bare URLs for their own rules' do
    source = '[text][missing] ![alt][unknown] https://example.test'
    expect(offenses(described_class, source, { 'AllowedLinkStyles' => [], 'AllowedImageStyles' => [] })).to be_empty
  end

  it 'excludes code, front matter, HTML and escaped delimiters' do
    source = <<~'MARKDOWN'
      ---
      title: "[text](url)"
      ---

      `[text](url)` ``<https://example.test> `tick` ``

      ~~~
      [text](url)
      ~~~

          [text](url)

      \[text](url)
      <!-- [text](url) -->
      <a href="url">[text](url)</a>
      <code>[text](url)</code>
    MARKDOWN
    expect(offenses(described_class, source, { 'AllowedLinkStyles' => [] })).to be_empty
  end
end
