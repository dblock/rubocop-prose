# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Prose::UndefinedReference do
  it 'reports full and collapsed references, including images, without guessing destinations' do
    source = '[guide][missing] [absent][] ![diagram][image]'
    result, rewritten = investigate(described_class, source)
    expect(result.map { |offense| offense.location.source }).to eq(
      ['[guide][missing]', '[absent][]', '![diagram][image]']
    )
    expect(rewritten).to eq(source)
  end

  it 'normalizes case and whitespace in IDs across lines and before definitions' do
    source = <<~MARKDOWN
      [long [nested]
      label][ GUIDE
      ID ] ![alt][guide id] [guide id][] [GUIDE ID]

      [Guide   ID]: <docs.md> "Guide"
    MARKDOWN
    expect(offenses(described_class, source)).to be_empty
  end

  it 'can opt in to ambiguous shortcut references but not task markers or footnotes' do
    source = "- [x] done\n- [ ] pending\n\n[ordinary prose] [^note]\n\n[^note]: A footnote\n"
    expect(offenses(described_class, source)).to be_empty
    result = offenses(described_class, source, { 'ShortcutSyntax' => true })
    expect(result.map { |offense| offense.location.source }).to eq(['[ordinary prose]'])
  end

  it 'handles escaped brackets, nested destinations and angle destinations' do
    source = '[a \[literal\]][id] [inline](path(a).md "Title") [angle](<path with spaces>)'
    expect(offenses(described_class, source).map { |offense| offense.location.source }).to eq(['[a \[literal\]][id]'])
  end

  it 'excludes front matter, code, HTML and escaped reference syntax' do
    source = <<~'MARKDOWN'
      ---
      title: "[text][missing]"
      ---

      `[text][missing]`

      ~~~
      [text][missing]
      ~~~

          [text][missing]

      \[text]\[missing]
      <!-- [text][missing] -->
      <code>[text][missing]</code>
      <a href="url">[text][missing]</a>
    MARKDOWN
    expect(offenses(described_class, source, { 'ShortcutSyntax' => true })).to be_empty
  end

  it 'does not allow definitions inside excluded code to resolve references' do
    source = "[text][missing]\n\n```\n[missing]: docs.md\n```\n"
    expect(offenses(described_class, source).length).to eq(1)
  end
end
