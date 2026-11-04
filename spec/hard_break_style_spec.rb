# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Markdown::HardBreakStyle do
  it 'uses the default backslash style and corrects whitespace hard breaks' do
    source = "First line.  \nSecond line.\n"
    expect(offenses(described_class, source).map(&:line)).to eq([1])
    expect(corrected(described_class, source)).to eq("First line.\\\nSecond line.\n")
  end

  it 'supports trailing spaces and cooperates with trailing-whitespace correction' do
    source = "First line.\\\nSecond line.\n"
    expect(corrected(described_class, source, 'Style' => 'spaces')).to eq("First line.  \nSecond line.\n")
    expect(corrected([described_class, RuboCop::Cop::Markdown::TrailingWhitespace], source,
                     settings: { 'Markdown/HardBreakStyle' => { 'Style' => 'spaces' } }))
      .to eq("First line.  \nSecond line.\n")
  end

  it 'retains literal backslashes before the hard-break marker' do
    source = "First line.#{'\\' * 2}\nSecond line.\n"
    rewritten = corrected(described_class, source, 'Style' => 'spaces')
    expect(rewritten).to eq("First line.\\  \nSecond line.\n")
    render = ->(text) { Kramdown::Document.new(text, input: 'GFM').to_html.gsub(/ +<br/, '<br') }
    expect(render.call(rewritten)).to eq(render.call(source))
  end

  it 'preserves Unicode locations, container prefixes, and CRLF line endings' do
    source = "> Café.  \r\n> Next.\r\n"
    offense = offenses(described_class, source).fetch(0)
    expect([offense.line, offense.location.column, offense.location.source]).to eq([1, 7, '  '])
    expect(corrected(described_class, source)).to eq(source)
  end

  it 'ignores soft breaks, code, and HTML breaks' do
    source = <<~'MARKDOWN'
      A soft
      break.
      `code\
      continues`
      A<br>
      B
    MARKDOWN
    expect(offenses(described_class, source)).to be_empty
  end

  it 'reports but does not autocorrect an ambiguous backslash before spaces' do
    source = "A\\  \nB\n"
    expect(offenses(described_class, source).map(&:line)).to eq([1])
    expect(corrected(described_class, source)).to eq(source)
  end

  it 'rejects styles other than backslash and spaces' do
    expect do
      offenses(described_class, "A  \nB\n", 'Style' => 'consistent')
    end.to raise_error(RuboCop::ValidationError, /Style must be backslash or spaces/)
  end
end
