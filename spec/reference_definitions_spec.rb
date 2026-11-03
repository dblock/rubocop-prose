# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Markdown::ReferenceDefinitions do
  it 'optionally allows identical normalized definitions but reports conflicting destinations and titles' do
    source = <<~MARKDOWN
      [docs]

      [docs]: <guide?a=1&amp;b=2> "Guide"
      [ DOCS ]: guide?a=1&b=2 "Guide"
      [docs]: other "Guide"
      [docs]: guide?a=1&b=2 "Other"
    MARKDOWN
    result = offenses(described_class, source, 'AllowIdenticalDuplicates' => true)
    expect(result.map { |offense| offense.location.line }).to eq([5, 6])
    expect(corrected(described_class, source, 'AllowIdenticalDuplicates' => true)).to eq(source)
  end

  it 'continues reporting unused definitions when identical duplicates are permitted' do
    source = "[docs]: guide\n[DOCS]: guide\n"
    expect(offenses(described_class, source, 'AllowIdenticalDuplicates' => true, 'CheckUnused' => true).size).to eq(2)
    expect(offenses(described_class, source).size).to eq(1)
  end

  it 'reports normalized duplicates at their own ranges while permitting unused definitions by default' do
    source = "[text][used]\n\n[used]: one.md\n[ USED ]: two.md\n[orphan]: unused.md\n"
    result, rewritten = investigate(described_class, source)
    expect(result.map { |offense| offense.location.source }).to eq(['[ USED ]: two.md'])
    expect(result.first.message).to include('Remove or rename the duplicate reference definition.')
    expect(rewritten).to eq(source)
  end

  it 'counts full, collapsed, shortcut and nested image references as uses' do
    source = <<~MARKDOWN
      [text][full] [collapsed][] [shortcut] ![image] [![alt][nested]](page.md)

      [full]: full.md
      [collapsed]: collapsed.md
      [shortcut]: shortcut.md
      [image]: diagram.svg
      [nested]: badge.svg
    MARKDOWN
    expect(offenses(described_class, source)).to be_empty
  end

  it 'preserves multiline definitions and their title ranges' do
    source = "[ unused\n ID ]:\n  <docs.md>\n  \"A title\"\n"
    expect(offenses(described_class, source, 'CheckUnused' => true).map { |offense| offense.location.source }).to eq([source.strip])
  end

  it 'recognizes references and continued definitions inside block quotes' do
    source = "> [guide][ GUIDE\n> ID ]\n>\n> [guide id]:\n>   <docs.md>\n>   \"A title\"\n"
    expect(offenses(described_class, source)).to be_empty
  end

  it 'configures ignored definitions and independent unused/duplicate checks' do
    source = "[//]: comment\n[other]: one.md\n[OTHER]: two.md\n"
    result = offenses(described_class, source, { 'CheckUnused' => false })
    expect(result.map { |offense| offense.location.source }).to eq(['[OTHER]: two.md'])
    ignored = { 'IgnoredDefinitions' => [' OTHER ', '//'] }
    expect(offenses(described_class, source, ignored)).to be_empty
    used = "[other]\n\n#{source}"
    expect(offenses(described_class, used, { 'CheckDuplicates' => false })).to be_empty
  end

  it 'does not count code or escaped references as uses' do
    source = "`[id]` \\[id]\n\n[id]: unused.md\n"
    expect(offenses(described_class, source, 'CheckUnused' => true).map { |offense| offense.location.source }).to eq(['[id]: unused.md'])
  end

  it 'excludes front matter, code, HTML, escaped definitions and footnotes' do
    source = <<~'MARKDOWN'
      ---
      title: metadata
      [meta]: unused.md
      ---

      `[span]: unused.md`

      ```
      [fenced]: unused.md
      ```

          [indented]: unused.md

      \[escaped]: unused.md
      <!-- [comment]: unused.md -->
      <pre>
      [raw]: unused.md
      </pre>

      [^note]: A footnote
    MARKDOWN
    expect(offenses(described_class, source)).to be_empty
  end
end
