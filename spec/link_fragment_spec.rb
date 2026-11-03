# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Prose::LinkFragment do
  it 'reports only unresolved local fragments and does not rewrite destinations' do
    source = "# Guide\n\n[ok](#guide) [bad](#missing) [file](other.md#missing) [web](https://example.test/#missing)\n"
    result, rewritten = investigate(described_class, source)
    expect(result.map { |offense| offense.location.source }).to eq(['[bad](#missing)'])
    expect(rewritten).to eq(source)
  end

  it 'uses collision-aware duplicate heading suffixes including natural numeric suffixes' do
    source = <<~MARKDOWN
      # Topic
      # Topic-1
      # Topic
      # Topic

      [one](#topic) [natural](#topic-1) [two](#topic-2) [three](#topic-3) [bad](#topic-4)
    MARKDOWN
    expect(offenses(described_class, source).map { |offense| offense.location.source }).to eq(['[bad](#topic-4)'])
  end

  it 'preserves Unicode and decodes percent escapes and entities in fragments and headings' do
    source = "# Café & Thé `API`\n# 日本語\n\n[cafe](#caf%C3%A9--th%C3%A9-api) [jp](#%E6%97%A5%E6%9C%AC%E8%AA%9E)\n"
    expect(offenses(described_class, source)).to be_empty
  end

  it 'recognizes setext headings supplied by the shared Markdown parser' do
    source = "A long heading\n-------\n\n[guide](#a-long-heading)\n"
    expect(offenses(described_class, source)).to be_empty
  end

  it 'matches explicit IDs, HTML anchors, and configured additional anchors' do
    source = <<~MARKDOWN
      # A heading {#explicit}

      <span id="custom&amp;id"></span>
      <a name="legacy"></a>
      <div>
      <span id="nested"></span>
      </div>

      [explicit](#explicit) [html](#custom&amp;id) [old](#legacy) [extra](#template) [nested](#nested)
    MARKDOWN
    expect(offenses(described_class, source, { 'AdditionalAnchors' => ['template'] })).to be_empty
  end

  it 'does not find anchors hidden in another HTML attribute value' do
    source = "<span title='id=\"fake\"'></span>\n\n[bad](#fake)\n"
    expect(offenses(described_class, source).length).to eq(1)
  end

  it 'does not treat HTML-looking titles and destinations as anchors' do
    source = "[guide](docs.md '<span id=\"fake\">') [bad](#fake)\n"
    expect(offenses(described_class, source).map { |offense| offense.location.source }).to eq(['[bad](#fake)'])
  end

  it 'supports renderer-style anchor algorithms rather than fetching other documents' do
    source = "# A -- B!\n\n[gitlab](#a-b)\n"
    expect(offenses(described_class, source, { 'Renderer' => 'gitlab' })).to be_empty
    expect(offenses(described_class, source, { 'Renderer' => 'github' }).length).to eq(1)
    ascii = "# 123 Café!\n\n[ascii](#caf)\n"
    expect(offenses(described_class, ascii, { 'Renderer' => 'kramdown' })).to be_empty
  end

  it 'resolves reference links, treats plus literally and matches case sensitively' do
    source = "# A B\n\n[guide][ LOCAL ] [case](#A-B) [plus](#a+b)\n\n[local]: #a-b\n"
    expect(offenses(described_class, source).map { |offense| offense.location.source }).to eq(
      ['[case](#A-B)', '[plus](#a+b)']
    )
  end

  it 'configures page-top fragments separately from empty destination checks' do
    source = '[top](#) ![image](#missing)'
    expect(offenses(described_class, source)).to be_empty
    expect(offenses(described_class, source, { 'AllowEmptyFragment' => false }).length).to eq(1)
  end

  it 'excludes code, front matter, escaped links, HTML links, and fake headings in code' do
    source = <<~'MARKDOWN'
      ---
      title: "[bad](#missing)"
      ---

      `[bad](#missing)`

      ```
      # Fake
      [bad](#missing)
      ```

          [bad](#missing)

      \[bad](#missing)
      <!-- <span id="fake"></span> [bad](#missing) -->
      <a href="#missing">link</a>
      <code>[bad](#missing)</code>
      [real](#fake)
    MARKDOWN
    expect(offenses(described_class, source).map { |offense| offense.location.source }).to eq(['[real](#fake)'])
  end
end
