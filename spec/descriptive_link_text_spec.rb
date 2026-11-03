# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Prose::DescriptiveLinkText do
  it 'reports whole generic labels rather than substrings and does not invent a correction' do
    source = '[click here](page.md) [HERE](page.md) [click here for installation](page.md)'
    result, rewritten = investigate(described_class, source)
    expect(result.map { |offense| offense.location.source }).to eq(['click here', 'HERE'])
    expect(rewritten).to eq(source)
  end

  it 'interprets formatting, code spans, entities and multiline whitespace in labels' do
    source = "[**Click**\n here](page.md) [`here`](page.md) [&#104;ere](page.md)\n"
    expect(offenses(described_class, source).map { |offense| offense.location.source }).to eq(
      ["**Click**\n here", '`here`', '&#104;ere']
    )
  end

  it 'supports project-specific generic labels and an empty allow-all policy' do
    source = '[Details](page.md) [here](page.md)'
    result = offenses(described_class, source, { 'GenericLabels' => [' DETAILS '] })
    expect(result.map { |offense| offense.location.source }).to eq(['Details'])
    expect(offenses(described_class, source, { 'GenericLabels' => [] })).to be_empty
  end

  it 'checks normalized references but not images, autolinks or undefined references' do
    source = "[Here][ ID ] [more][] [LINK] ![here](img.svg) <https://example.test> [here][unknown]\n\n[id]: page.md\n[more]: page.md\n[link]: page.md\n"
    expect(offenses(described_class, source).map { |offense| offense.location.source }).to eq(%w[Here more LINK])
  end

  it 'uses the alternative text of an image inside a link' do
    source = '[![here](badge.svg)](page.md) [![Build status](badge.svg)](page.md)'
    expect(offenses(described_class, source).map { |offense| offense.location.source }).to eq(['![here](badge.svg)'])
  end

  it 'decodes rendered label entities exactly once' do
    source = '[&amp;#104;ere](page.md) [&#104;ere](page.md)'
    expect(offenses(described_class, source).map { |offense| offense.location.source }).to eq(['&#104;ere'])
  end

  it 'excludes code, front matter, escaped syntax and HTML' do
    source = <<~'MARKDOWN'
      ---
      title: "[here](url)"
      ---

      `[here](url)`

      ```
      [here](url)
      ```

          [here](url)

      \[here](url)
      <!-- [here](url) -->
      <a href="url">[here](url)</a>
      <code>[here](url)</code>
    MARKDOWN
    expect(offenses(described_class, source)).to be_empty
  end
end
