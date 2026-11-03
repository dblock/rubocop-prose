# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Prose::LinkTextSpacing do
  it 'corrects only the label, preserving Unicode positions, nested text, destination and title' do
    source = "Résumé [ guide [v2] ](docs/a(b).md \"Guide\")\n"
    result, rewritten = investigate(described_class, source)
    expect(result.map { |offense| offense.location.source }).to eq([' guide [v2] '])
    expect(rewritten).to eq("Résumé [guide [v2]](docs/a(b).md \"Guide\")\n")
    expect(corrected(described_class, rewritten)).to eq(rewritten)
    expect(offenses(described_class, rewritten)).to be_empty
  end

  it 'trims multiline label boundaries without changing their interior' do
    source = "[ \nlong [nested]\nlabel \t](docs.md)\n"
    expect(corrected(described_class, source)).to eq("[long [nested]\nlabel](docs.md)\n")
  end

  it 'preserves normalized identities for full, collapsed and shortcut references' do
    source = "[ label ][ID] [ id ][] [ ID ]\n\n[id]: docs.md\n"
    expected = "[label][ID] [id][] [ID]\n\n[id]: docs.md\n"
    expect(offenses(described_class, source).length).to eq(3)
    expect(corrected(described_class, source)).to eq(expected)
    expect(offenses(described_class, expected)).to be_empty
  end

  it 'accepts unpadded labels, images, empty labels and unresolved references' do
    source = "[guide](docs.md) ![ padded alt ](image.png) [](docs.md) [ missing ][unknown]\n"
    expect(offenses(described_class, source)).to be_empty
  end

  it 'reports whitespace-only labels without an unsafe correction' do
    source = '[   ](docs.md)'
    result, rewritten = investigate(described_class, source)
    expect(result.length).to eq(1)
    expect(rewritten).to eq(source)
  end

  it 'excludes code, front matter, escapes and HTML' do
    source = <<~'MARKDOWN'
      ---
      title: "[ padded ](url)"
      ---

      `[ padded ](url)`

      ~~~
      [ padded ](url)
      ~~~

          [ padded ](url)

      \[ padded ](url)
      <!-- [ padded ](url) -->
      <code>[ padded ](url)</code>
      <a href="url">[ padded ](url)</a>
    MARKDOWN
    expect(offenses(described_class, source)).to be_empty
    expect(corrected(described_class, source)).to eq(source)
  end
end
