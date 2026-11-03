# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Markdown::ImageAltText do
  it 'reports blank image descriptions without fabricating a correction' do
    source = "![](diagram.svg) ![ \t ](diagram.svg)\n"
    result, rewritten = investigate(described_class, source)
    expect(result.map { |offense| offense.location.source }).to eq(['![](diagram.svg)', "![ \t ](diagram.svg)"])
    expect(rewritten).to eq(source)
  end

  it 'finds images nested in links and preserves their exact Unicode positions' do
    source = "Résumé [![](badge.svg)](https://example.test)\n"
    result = offenses(described_class, source)
    expect(result.map { |offense| offense.location.source }).to eq(['![](badge.svg)'])
    expect(result.first.column).to eq(8)
  end

  it 'resolves reference images and renders entities in alternative text' do
    source = "![][ IMAGE ] ![&#32;][image] ![diagram][image]\n\n[image]: diagram.svg\n"
    expect(offenses(described_class, source).map { |offense| offense.location.source }).to eq(
      ['![][ IMAGE ]', '![&#32;][image]']
    )
  end

  it 'accepts descriptive nested text, collapsed/shortcut images and unknown references' do
    source = "![flow [v2]](diagram.svg) ![diagram][] ![DIAGRAM] ![][unknown]\n\n[diagram]: diagram.svg\n"
    expect(offenses(described_class, source)).to be_empty
  end

  it 'excludes code, front matter, HTML and escaped image syntax' do
    source = <<~'MARKDOWN'
      ---
      image: "![](diagram.svg)"
      ---

      `![](diagram.svg)`

      ~~~
      ![](diagram.svg)
      ~~~

          ![](diagram.svg)

      !\[](diagram.svg)
      \![](diagram.svg)
      <!-- ![](diagram.svg) -->
      <code>![](diagram.svg)</code>
      <img src="diagram.svg" alt="">
    MARKDOWN
    expect(offenses(described_class, source)).to be_empty
  end
end
