# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Markdown::ImagePathSeparators do
  it 'corrects local inline separators while preserving Markdown escapes and Unicode locations' do
    source = "Résumé ![diagram](images\\diagram\\(v2\\).png)\n"
    result, rewritten = investigate(described_class, source)
    expect(result.map { |offense| offense.location.source }).to eq(['\\'])
    expect(result.first.location.begin_pos).to eq(source.index('\\'))
    expect(rewritten).to eq("Résumé ![diagram](images/diagram\\(v2\\).png)\n")
    expect(corrected(described_class, rewritten)).to eq(rewritten)
    expect(offenses(described_class, rewritten)).to be_empty
  end

  it 'maps angle-bracket destinations through optional titles' do
    source = '![diagram](<images\diagram.png> "Diagram")'
    result, rewritten = investigate(described_class, source)
    expect(result.map { |offense| offense.location.source }).to eq(['\\'])
    expect(rewritten).to eq('![diagram](<images/diagram.png> "Diagram")')
  end

  it 'checks destinations used by resolved image references, not unrelated link definitions' do
    source = <<~'MARKDOWN'
      ![diagram][picture]
      ![again][picture]
      [linked page][page]

      [picture]: images\diagram.png
      [page]: docs\guide.md
      [unused]: assets\other.png
    MARKDOWN
    result, rewritten = investigate(described_class, source)
    expect(result.map { |offense| offense.location.source }).to eq(['\\'])
    expect(rewritten).to eq(source.sub('images\\diagram.png', 'images/diagram.png'))
  end

  it 'reports ambiguous consecutive backslashes without correcting them' do
    source = <<~'MARKDOWN'
      ![diagram](images\\diagram.png)
    MARKDOWN
    result, rewritten = investigate(described_class, source)
    expect(result.map { |offense| offense.location.source }).to eq(['\\'])
    expect(rewritten).to eq(source)
  end

  it 'ignores escapes, external destinations, ordinary links, unresolved references, code, and metadata' do
    source = <<~'MARKDOWN'
      ---
      image: ![metadata](images\diagram.png)
      ---

      ![escaped](images/diagram\(v2\).png)
      ![external](https://example.test/images\diagram.png)
      ![protocol relative](//example.test/images\diagram.png)
      [link](images\diagram.png)
      ![missing][unresolved]
      `![code](images\diagram.png)`

      ```markdown
      ![fenced](images\diagram.png)
      ```
    MARKDOWN
    expect(offenses(described_class, source)).to be_empty
    expect(corrected(described_class, source)).to eq(source)
  end

  it 'checks Windows drive destinations as local paths' do
    source = '![diagram](C:\images\diagram.png)'
    result, rewritten = investigate(described_class, source)
    expect(result.map { |offense| offense.location.source }).to eq(['\\', '\\'])
    expect(rewritten).to eq('![diagram](C:/images/diagram.png)')
  end
end
