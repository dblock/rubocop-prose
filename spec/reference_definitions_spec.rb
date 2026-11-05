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
    result = offenses(described_class, source, 'Duplicates' => 'allow_identical')
    expect(result.map { |offense| offense.location.line }).to eq([5, 6])
    expect(corrected(described_class, source, 'Duplicates' => 'allow_identical')).to eq(source)
  end

  it 'continues reporting unused definitions when identical duplicates are permitted' do
    source = "[docs]: guide\n[DOCS]: guide\n"
    result = offenses(described_class, source, 'Duplicates' => 'allow_identical', 'Unused' => true)
    expect(result.size).to eq(2)
    expect(result.map(&:message)).to all(include('Reference definition is not used.'))
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
    expect(offenses(described_class, source, 'Unused' => true).map { |offense| offense.location.source }).to eq([source.strip])
  end

  it 'recognizes references and continued definitions inside block quotes' do
    source = "> [guide][ GUIDE\n> ID ]\n>\n> [guide id]:\n>   <docs.md>\n>   \"A title\"\n"
    expect(offenses(described_class, source)).to be_empty
  end

  it 'configures ignored definitions and independent unused/duplicate checks' do
    source = "[//]: comment\n[other]: one.md\n[OTHER]: two.md\n"
    result = offenses(described_class, source, { 'Unused' => false })
    expect(result.map { |offense| offense.location.source }).to eq(['[OTHER]: two.md'])
    ignored = { 'IgnoredDefinitions' => [' OTHER ', '//'] }
    expect(offenses(described_class, source, ignored)).to be_empty
    used = "[other]\n\n#{source}"
    expect(offenses(described_class, used, { 'Duplicates' => 'allow' })).to be_empty
  end

  it 'does not count code or escaped references as uses' do
    source = "`[id]` \\[id]\n\n[id]: unused.md\n"
    expect(offenses(described_class, source, 'Unused' => true).map { |offense| offense.location.source }).to eq(['[id]: unused.md'])
  end

  it 'forbids identical definitions explicitly and by default' do
    source = "[docs]\n\n[docs]: guide\n[DOCS]: guide\n"
    [nil, 'forbid'].each do |policy|
      options = policy ? { 'Duplicates' => policy } : {}
      result, rewritten = investigate(described_class, source, options)
      expect(result.map { |offense| offense.location.source }).to eq(['[DOCS]: guide'])
      expect(rewritten).to eq(source)
    end
  end

  it 'allows conflicting duplicates without disabling independent unused checks or ignored IDs' do
    source = "[used]\n\n[used]: one\n[USED]: two\n[orphan]: one\n[ORPHAN]: two\n[//]: one\n[//]: two\n"
    expect(offenses(described_class, source, 'Duplicates' => 'allow')).to be_empty
    options = { 'Duplicates' => 'allow', 'Unused' => true }
    result, rewritten = investigate(described_class, source, options)
    expect(result.map { |offense| offense.location.line }).to eq([5, 6])
    expect(result.map(&:message)).to all(include('Reference definition is not used.'))
    expect(rewritten).to eq(source)
    expect(offenses(described_class, source, options.merge('IgnoredDefinitions' => [' ORPHAN ', '//']))).to be_empty
  end

  it 'reports unused then duplicate diagnostics in source order without checking ignored duplicates' do
    source = "[orphan]: one\n[ORPHAN]: two\n[//]: one\n[//]: two\n"
    result, rewritten = investigate(described_class, source, 'Unused' => true)
    expect(result.map { |offense| offense.location.line }).to eq([1, 2])
    expect(result[0].message).to include('Reference definition is not used.')
    expect(result[1].message).to include('Remove or rename the duplicate reference definition.')
    expect(rewritten).to eq(source)
  end

  it 'compares decoded escaped destinations and exact titles against the first definition' do
    source = <<~'MARKDOWN'
      [docs]

      [docs]: guide\(one\) "A & B"
      [DOCS]: <guide(one)> "A & B"
      [docs]: other "A & B"
      [docs]: other "A & B"
      [docs]: <guide(one)> "Different"
      [docs]: <guide(one)> "A &amp; B"
    MARKDOWN
    result = offenses(described_class, source, 'Duplicates' => 'allow_identical')
    expect(result.map { |offense| offense.location.line }).to eq([5, 6, 7, 8])
  end

  it 'rejects invalid duplicate policies and nonboolean unused settings explicitly' do
    [nil, true, false, 'identical', 'ALLOW', 1, []].each do |value|
      expect { offenses(described_class, "[id]: guide\n", 'Duplicates' => value) }
        .to raise_error(RuboCop::ValidationError, /Duplicates must be forbid, allow_identical, or allow/)
    end
    [nil, 'true', 'false', 0, 1, []].each do |value|
      expect { offenses(described_class, "[id]: guide\n", 'Unused' => value) }
        .to raise_error(RuboCop::ValidationError, /Unused must be true or false/)
    end
  end

  it 'rejects legacy options with explicit combination mappings rather than translating them' do
    {
      'CheckDuplicates' => false, 'AllowIdenticalDuplicates' => true, 'CheckUnused' => false
    }.each do |key, value|
      config = RuboCop::Config.new({ 'Markdown/ReferenceDefinitions' => { key => value } }, '.rubocop.yml')
      guidance = if key == 'CheckUnused'
                   /Replace CheckUnused with Unused/
                 else
                   /CheckDuplicates: false maps to Duplicates: allow.*CheckDuplicates: true.*Duplicates: allow_identical.*default maps to Duplicates: forbid/m
                 end
      expect { RuboCop::ConfigObsoletion.new(config).reject_obsolete! }
        .to raise_error(RuboCop::ValidationError, guidance)
      expect(config['Markdown/ReferenceDefinitions']).to eq(key => value)
    end
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
