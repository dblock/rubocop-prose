# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Prose::EmptyLink do
  it 'reports empty destinations and page-top placeholders, not empty visible text' do
    source = '[empty]() [space]( ) [top](#) [angle](<>) [title]( "" ) [](real.md)'
    result, rewritten = investigate(described_class, source)
    expect(result.map { |offense| offense.location.source }).to eq(
      ['[empty]()', '[space]( )', '[top](#)', '[angle](<>)', '[title]( "" )']
    )
    expect(rewritten).to eq(source)
  end

  it 'resolves full, collapsed and shortcut references to empty definitions' do
    source = "[full][ ID ] [id][] [ID]\n\n[id]: <> \"An empty destination\"\n"
    expect(offenses(described_class, source).length).to eq(3)
  end

  it 'decodes Markdown escapes and entities without treating real fragments as empty' do
    source = '[top](&#35;) [fragment](#heading) [escaped](\#) ![alt]() [unknown][id]'
    expect(offenses(described_class, source).map { |offense| offense.location.source }).to eq(
      ['[top](&#35;)', '[escaped](\#)']
    )
  end

  it 'supports nested and multiline link text with titled destinations' do
    source = "[a [nested]\nlabel](<> 'title')\n"
    expect(offenses(described_class, source).first.location.source).to eq(source.strip)
  end

  it 'excludes code, front matter, HTML and escaped syntax' do
    source = <<~'MARKDOWN'
      ---
      title: "[empty]()"
      ---

      `[empty]()`

      ```
      [empty]()
      ```

          [empty]()

      \[empty]()
      <!-- [empty]() -->
      <a href="">[empty]()</a>
      <code>[empty]()</code>
    MARKDOWN
    expect(offenses(described_class, source)).to be_empty
  end
end
