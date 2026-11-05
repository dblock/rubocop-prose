# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Prose::SentenceCapitalization do
  it 'checks paragraph openings in Markdown containers and inline prose' do
    source = <<~MARKDOWN
      ---
      title: lowercase
      ---

      lowercase prose.

      > “quoted” prose.

      *emphasized* prose.

      [linked](https://example.test) prose.

      - lowercase list opening.

        later paragraph.

      | cell |
      | --- |
      | lowercase |

      # lowercase heading

      ```text
      lowercase code
      ```

      A paragraph with a note.[^1]

      [^1]: lowercase footnote paragraph.
    MARKDOWN
    expect(offenses(described_class, source).map { |offense| [offense.line, offense.location.source] }).to eq(
      [[5, 'l'], [7, 'q'], [9, 'e'], [11, 'l'], [15, 'l'], [29, 'l']]
    )
  end

  it 'detects lowercase literal code and quoted openings through emphasis and links without correcting them' do
    source = <<~MARKDOWN
      `fixed` requires one space.

      `snake_case` is an identifier.

      **`fixed`** requires one space.

      "aligned" adds padding.

      “*aligned*” adds padding.

      [`aligned`](guide.md) is a link label.

      `MixedCase` is preserved.
    MARKDOWN
    found = offenses(described_class, source)
    expect(found.map(&:line)).to eq([1, 3, 5, 7, 9, 11])
    expect(corrected(described_class, source)).to eq(source)
  end

  it 'skips ambiguous bare identifiers and URL-like paragraph openings' do
    source = "snake_case is a key.\n\nhttps://example.test is a URL.\n\nfile.md is a path.\n"
    expect(offenses(described_class, source)).to be_empty
  end

  it 'maps unsafe corrections to footnote paragraph source text' do
    source = "A paragraph with a note.[^1]\n\n[^1]: lowercase footnote paragraph.\n"
    expected = "A paragraph with a note.[^1]\n\n[^1]: Lowercase footnote paragraph.\n"
    expect(corrected(described_class, source)).to eq(expected)
  end

  it 'corrects only mapped ordinary prose with unsafe autocorrection' do
    source = "> **écrire** le texte.\n\n[lowercase](guide.md) prose.\n"
    expected = "> **Écrire** le texte.\n\n[Lowercase](guide.md) prose.\n"
    result = corrected(described_class, source)
    expect(result).to eq(expected)
    expect(corrected(described_class, result)).to eq(result)
  end

  it 'honors exact ignored words and mixed-case brand preservation' do
    source = "eBay ships products.\n\nnpm installs packages.\n\nNpm starts a sentence.\n"
    expect(offenses(described_class, source, 'IgnoredWords' => ['Npm']).map(&:line)).to eq([3])
  end

  it 'honors native RuboCop suppression directives for intentional literal openings' do
    source = <<~MARKDOWN
      <!-- # rubocop:disable Prose/SentenceCapitalization -->
      `fixed` requires one space.
      <!-- # rubocop:enable Prose/SentenceCapitalization -->

      `fixed` requires one space.
    MARKDOWN
    expect(offenses(described_class, source).map(&:line)).to eq([5])
  end

  it 'checks subsequent list-item paragraphs but leaves item openings to ListItemCapitalization' do
    settings = {
      'Markdown/ListItemCapitalization' => {
        'Enabled' => true, 'EnforcedStyle' => 'consistent'
      }
    }
    source = "- lowercase item\n- `fixed` item\n\n  lowercase continuation\n"
    found = offenses(described_class, source, settings: settings)
    expect(found.map(&:line)).to eq([4])
  end

  it 'checks literal plain-text paragraphs without parsing Markdown-like inline syntax' do
    source = "  lowercase prose begins here.\ncontinued text.\n\n\"quoted\" literal.\n\n`code`-like text.\n\n*emphasis* text.\n"
    found = offenses(described_class, source, path: 'example.txt')
    expect(found.map { |offense| [offense.line, offense.column, offense.location.source] }).to eq(
      [[1, 2, 'l'], [4, 1, 'q']]
    )
    expect(corrected(described_class, source, path: 'example.txt')).to eq(
      "  Lowercase prose begins here.\ncontinued text.\n\n\"quoted\" literal.\n\n`code`-like text.\n\n*emphasis* text.\n"
    )
  end

  it 'is disabled by default with one supported style and unsafe correction' do
    configuration = RuboCop::Prose.default_configuration.fetch('Prose/SentenceCapitalization')
    expect(configuration).to include(
      'Enabled' => false, 'SafeAutoCorrect' => false, 'EnforcedStyle' => 'initial_capital',
      'PreserveMixedCase' => true, 'IgnoredWords' => [], 'SupportedStyles' => ['initial_capital']
    )
  end
end
