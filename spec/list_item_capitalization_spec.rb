# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Markdown::ListItemCapitalization do
  it 'corrects mismatched initials relative to the first prose sibling' do
    source = "- Build the package\n- run the tests.\n- Ship it!\n"
    found = offenses(described_class, source)
    expect(found.map { |offense| [offense.line, offense.column, offense.location.source] }).to eq([[2, 2, 'r']])
    expect(found.first.message).to include('uppercase')
    expect(corrected(described_class, source)).to eq("- Build the package\n- Run the tests.\n- Ship it!\n")
  end

  it 'accepts lowercase siblings independently of punctuation' do
    source = "1. build the package.\n2. run the tests\n3. Ship it!\n"
    found = offenses(described_class, source)
    expect(found.map(&:line)).to eq([3])
    expect(found.first.message).to include('lowercase')
  end

  it 'checks nested and separate lists independently, including quoted lists' do
    source = <<~MARKDOWN
      - Build the package
        1. run tests
        2. Ship it
      - Run the checks

      > - start here
      >   - Nested prose
      >   - more prose
      > - Finish here
    MARKDOWN
    expect(offenses(described_class, source).map(&:line)).to eq([3, 9, 8])
  end

  it 'finds first prose letters inside emphasis and links without inspecting destinations' do
    source = "- **Build** it\n- [*run* tests](UPPERCASE)\n- _ship_ it\n- [`code`](url) first\n"
    found = offenses(described_class, source)
    expect(found.map { |offense| [offense.line, offense.column, offense.location.source] }).to eq(
      [[2, 4, 'r'], [3, 3, 's'], [4, 4, 'c']]
    )
  end

  it 'ignores initial code even inside formatting and does not use it to establish a style' do
    source = "- `Build` prose\n- **`Run`** prose\n- start here\n- finish here\n"
    expect(offenses(described_class, source)).to be_empty
  end

  it 'compares literal code and quoted openings but never changes their contents' do
    source = "- Build it\n- `run` tests\n- \"ship\" it\n- `run_code` is an identifier.\n"
    options = { 'EnforcedStyle' => 'initial_capital' }
    found = offenses(described_class, source, options)
    expect(found.map { |offense| [offense.line, offense.location.source] }).to eq(
      [[2, 'r'], [3, 's'], [4, 'r']]
    )
    expect(corrected(described_class, source, options)).to eq(source)
  end

  it 'checks a lowercase literal in initial-capital mode without using it as a consistency baseline' do
    source = "- `lowercase` is a literal term.\n"
    expect(offenses(described_class, source).map(&:line)).to be_empty
    expect(offenses(described_class, source, 'EnforcedStyle' => 'initial_capital').map(&:line)).to eq([1])
  end

  it 'exempts configured initial words with exact spelling without establishing a style' do
    source = "- GitHub builds\n- iPhone releases\n- Paris trips\n- ruby commands\n- start here\n- finish here\n"
    expect(offenses(described_class, source, 'IgnoredWords' => %w[GitHub iPhone Paris ruby])).to be_empty
    expect(offenses(described_class, "- Build it\n- ruby commands\n- Ruby commands\n",
                    'IgnoredWords' => ['Ruby']).map(&:line)).to eq([2])
  end

  it 'skips ambiguous identifiers and non-prose items instead of inferring grammar' do
    source = <<~MARKDOWN
      - Build it
      - foo_bar
      - **foo**_bar
      - **camel**Case options
      - camelCase options
      - API endpoints
      - file.md
      - path/to/file
      - https://example.com
      - <https://example.com>
      - 123 things
      - ![image](picture.png)
      - <span>lowercase</span>
      - &alpha; values
      - "quoted prose"
      - 中文
    MARKDOWN
    expect(offenses(described_class, source).map { |offense| [offense.line, offense.location.source] }).to eq([[15, 'q']])
  end

  it 'handles task markers and Unicode character-based locations' do
    source = "> - [x] **Écrire** le texte\n> - [ ] [étudier](url) le texte\n> - [X] e\u0301crire encore\n"
    found = offenses(described_class, source)
    expect(found.map { |offense| [offense.line, offense.column, offense.location.source] }).to eq(
      [[2, 9, 'é'], [3, 8, 'e']]
    )
  end

  it 'treats Unicode titlecase letters as uppercase initials' do
    source = "- ǅungla text\n- être prêt\n- Écrire encore\n"
    expect(offenses(described_class, source).map { |offense| offense.location.source }).to eq(['ê'])
  end

  it 'checks child lists starting on the parent marker line without adopting their style' do
    source = "- - start here\n  - Finish here\n- Build the package\n- Run the tests\n"
    found = offenses(described_class, source)
    expect(found.map { |offense| [offense.line, offense.column] }).to eq([[2, 4]])
  end

  it 'ignores code blocks, headings, later paragraphs, and items beginning with nested lists' do
    source = <<~MARKDOWN
      - Build it

        later paragraph
      - # heading
      - `code`
      -
        - nested prose
        - other prose

      ```
      - Build it
      - run it
      ```
    MARKDOWN
    expect(offenses(described_class, source)).to be_empty
  end

  it 'does not inspect plain text even when explicitly enabled' do
    expect(offenses(described_class, "- Build it\n- run it\n", path: 'example.txt')).to be_empty
  end

  it 'requires initial capitals without using the first sibling as a baseline' do
    source = "- build the package\n- run the tests\n- Ship it\n"
    options = { 'EnforcedStyle' => 'initial_capital' }
    expect(offenses(described_class, source, options).map(&:line)).to eq([1, 2])
    expect(corrected(described_class, source, options)).to eq("- Build the package\n- Run the tests\n- Ship it\n")
  end

  it 'checks title case with customized minor and ignored words' do
    source = "- getting started with npm\n- Using the API\n- Using The API\n"
    options = { 'EnforcedStyle' => 'title_case', 'MinorWords' => ['THE'], 'IgnoredWords' => ['npm'] }
    expect(offenses(described_class, source, options).map(&:line)).to eq([1, 3])
    expect(corrected(described_class, source, options)).to eq(
      "- Getting Started With npm\n- Using the API\n- Using the API\n"
    )
  end

  it 'makes mixed-case preservation configurable in both initial styles' do
    source = "- Build it\n- macOS support\n"
    %w[consistent initial_capital].each do |style|
      options = { 'EnforcedStyle' => style }
      expect(offenses(described_class, source, options)).to be_empty
      expect(corrected(described_class, source, options.merge('PreserveMixedCase' => false))).to eq(
        "- Build it\n- MacOS support\n"
      )
    end
  end

  it 'corrects lowercase consistency with Unicode, markup and task markers' do
    source = "> - [x] **écrire** le texte\n> - [ ] [Étudier](url) le texte\n"
    result = corrected(described_class, source)
    expect(result).to eq("> - [x] **écrire** le texte\n> - [ ] [étudier](url) le texte\n")
    expect(corrected(described_class, result)).to eq(result)
  end

  it 'corrects title case without changing containers, task checkboxes or nested lists' do
    source = "> - [x] getting started with macOS\n>   - using the API\n"
    options = { 'EnforcedStyle' => 'title_case' }
    expected = "> - [x] Getting Started with macOS\n>   - Using the API\n"
    expect(corrected(described_class, source, options)).to eq(expected)
  end

  it 'withholds title corrections for split markup and links and skips opaque content' do
    source = "- getting **started**\n- [getting started](url)\n- using `code` with ruby\n"
    options = { 'EnforcedStyle' => 'title_case' }
    expect(offenses(described_class, source, options).map(&:line)).to eq([1, 2])
    expect(corrected(described_class, source, options)).to eq(source)
  end

  it 'does not rewrite identifiers or URLs in title-case items' do
    source = "- Using foo_bar\n- https://example.com\n"
    expect(corrected(described_class, source, 'EnforcedStyle' => 'title_case')).to eq(source)
  end

  it 'rejects invalid styles and word settings' do
    [
      { 'EnforcedStyle' => 'sentence_case' },
      { 'IgnoredWords' => ['two words'] },
      { 'MinorWords' => 'the' },
      { 'PreserveMixedCase' => 'false' }
    ].each do |options|
      expect { offenses(described_class, "- Example\n", options) }.to raise_error(RuboCop::ValidationError)
    end
  end
end
