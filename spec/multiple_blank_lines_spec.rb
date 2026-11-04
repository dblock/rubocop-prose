# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Prose::MultipleBlankLines do
  it 'reduces excess blank lines without merging paragraphs and stabilizes' do
    result = corrected(described_class, "First.\n\n\n\nSecond.\n")
    expect(result).to eq("First.\n\nSecond.\n")
    expect(offenses(described_class, result)).to be_empty
  end

  it 'retains blanks inside code and front matter' do
    source = "---\ntext: |\n\n\n  metadata\n---\n\n```\none\n\n\nthree\n```\n"
    expect(corrected(described_class, source)).to eq(source)
  end

  it 'allows configured limits but reports zero without deleting paragraph separation' do
    source = "First.\n\nSecond.\n"
    expect(offenses(described_class, source, 'Max' => 2)).to be_empty
    expect(offenses(described_class, source, 'Max' => 0).length).to eq(1)
    expect(corrected(described_class, source, 'Max' => 0)).to eq(source)
  end

  it 'retains only the heading minimum at each boundary with original Unicode locations' do
    settings = { 'Markdown/HeadingBlankLines' => { 'Enabled' => true, 'LinesAbove' => 2, 'LinesBelow' => 3 } }
    source = "Préface.\n\n\n\n# Tête\n\n\n\n\nText.\n\n\nOther.\n"
    result = corrected(described_class, source, settings: settings)

    expect(offenses(described_class, source, settings: settings).map { |offense| [offense.line, offense.column] })
      .to eq([[4, 0], [9, 0], [12, 0]])
    expect(result).to eq("Préface.\n\n\n# Tête\n\n\n\nText.\n\nOther.\n")
    expect(offenses(described_class, result, settings: settings)).to be_empty
  end

  it 'uses the larger minimum between Setext and ATX headings rather than adding them' do
    settings = { 'Markdown/HeadingBlankLines' => { 'Enabled' => true, 'LinesAbove' => 3, 'LinesBelow' => 2 } }
    source = "Title\n=====\n\n\n\n\n## Next\n\n\n\nText.\n"

    expect(corrected(described_class, source, settings: settings))
      .to eq("Title\n=====\n\n\n\n## Next\n\n\nText.\n")
  end

  it 'does not relax Max for disabled, excluded, or zero-minimum structural cops' do
    source = "Before.\n\n\n\n# Title\n\n\n\n```\nx\n```\n\n\n\nAfter.\n"
    expected = "Before.\n\n# Title\n\n```\nx\n```\n\nAfter.\n"
    [
      { 'Enabled' => false, 'LinesAbove' => 3, 'LinesBelow' => 3 },
      { 'Enabled' => true, 'LinesAbove' => 0, 'LinesBelow' => 0 },
      { 'Enabled' => true, 'LinesAbove' => 3, 'LinesBelow' => 3, 'Exclude' => ['**/*.md'] },
      { 'Enabled' => true, 'LinesAbove' => 3, 'LinesBelow' => 3, 'Include' => ['**/*.other'] }
    ].each do |options|
      settings = { 'Markdown/HeadingBlankLines' => options, 'Markdown/FenceBlankLines' => options }
      expect(corrected(described_class, source, settings: settings)).to eq(expected)
    end
  end

  it 'does not reserve heading or fence padding at document or front-matter boundaries' do
    settings = {
      'Markdown/HeadingBlankLines' => { 'Enabled' => true, 'LinesAbove' => 3, 'LinesBelow' => 3 },
      'Markdown/FenceBlankLines' => { 'Enabled' => true, 'LinesAbove' => 3, 'LinesBelow' => 3 }
    }
    ['# Title', "```\nx\n```"].each do |structure|
      source = "---\ntitle: Guide\n---\n\n\n\n#{structure}\n\n\n\n"
      expect(corrected(described_class, source, settings: settings))
        .to eq("---\ntitle: Guide\n---\n\n#{structure}\n\n")
    end
  end

  it 'counts marker-only blank lines toward the minimum without changing their prefixes' do
    settings = { 'Markdown/HeadingBlankLines' => { 'Enabled' => true, 'LinesAbove' => 0, 'LinesBelow' => 3 } }
    source = "> # Tête\n>\n\n\n\n> Text.\n\n\nOther.\n"

    expect(corrected(described_class, source, settings: settings)).to eq("> # Tête\n>\n\n\n> Text.\n\nOther.\n")
  end

  it 'respects list-item fence exclusions and does not pad above inline list fences' do
    source = "Intro.\n\n\n\n- ```ruby\n  x\n  ```\n\n\n\n  After.\n"
    settings = {
      'Markdown/FenceBlankLines' => { 'Enabled' => true, 'LinesAbove' => 3, 'LinesBelow' => 3, 'ListItems' => false },
      'Markdown/ListBlankLines' => { 'Enabled' => false }
    }
    expect(corrected(described_class, source, settings: settings))
      .to eq("Intro.\n\n- ```ruby\n  x\n  ```\n\n  After.\n")

    settings['Markdown/FenceBlankLines']['ListItems'] = true
    expect(corrected(described_class, source, settings: settings))
      .to eq("Intro.\n\n- ```ruby\n  x\n  ```\n\n\n\n  After.\n")
  end

  it 'honors the one-line list and table minimums even when Max is zero' do
    source = "Before.\n\n- item\n\nAfter.\n\n| a |\n| --- |\n\nEnd.\n\nOther.\n"

    expect(offenses(described_class, source, 'Max' => 0).map(&:line)).to eq([11])
    expect(corrected(described_class, source, 'Max' => 0)).to eq(source)
    settings = { 'Markdown/ListBlankLines' => { 'Enabled' => false },
                 'Markdown/TableBlankLines' => { 'Enabled' => false } }
    expect(offenses(described_class, source, { 'Max' => 0 }, settings: settings).map(&:line))
      .to eq([2, 4, 6, 9, 11])
  end

  it 'does not interpret structural minimums in plain text' do
    settings = {
      'Markdown/HeadingBlankLines' => { 'Enabled' => true, 'LinesAbove' => 3, 'LinesBelow' => 3 },
      'Markdown/FenceBlankLines' => { 'Enabled' => true, 'LinesAbove' => 3, 'LinesBelow' => 3 }
    }
    source = "Before.\n\n\n\n# Title\n\n\n\n```\nx\n\n\n\n```\n\n\n\nAfter.\n"

    expect(corrected(described_class, source, path: 'example.txt', settings: settings))
      .to eq("Before.\n\n# Title\n\n```\nx\n\n```\n\nAfter.\n")
  end

  it 'uses effective inherited configuration for each file without leaking structural minimums' do
    # Do not load this project's plugins through inherited parent exclusions.
    allow(RuboCop::ConfigLoader).to receive(:ignore_parent_exclusion?).and_return(true)
    root = File.expand_path('fixtures/configuration/structural_blank_lines', __dir__)
    store = RuboCop::ConfigStore.new
    parent = store.for_file(File.join(root, 'input.md'))
    child = store.for_file(File.join(root, 'child/input.md'))
    source = "Before.\n\n\n\n# Title\n\n\n\nAfter.\n"

    results = [parent, child, parent].map { |configuration| corrected(described_class, source, settings: configuration.to_h) }
    parent_result = "Before.\n\n\n# Title\n\n\nAfter.\n"
    child_result = "Before.\n\n# Title\n\nAfter.\n"
    expect(results).to eq([parent_result, child_result, parent_result])
  end

  it 'reduces quote-only blank lines inside one parsed blockquote and stabilizes' do
    source = "> First paragraph.\n>\n>\n> Second paragraph.\n"
    result = corrected(described_class, source)
    expect(result).to eq("> First paragraph.\n>\n> Second paragraph.\n")
    expect(offenses(described_class, result)).to be_empty
    expect(corrected(described_class, result)).to eq(result)
  end

  it 'preserves nested quote prefixes and respects the configured limit' do
    source = "> > First.\n> >\n> >\n> > Second.\n"
    expect(offenses(described_class, source, 'Max' => 2)).to be_empty
    expect(corrected(described_class, source)).to eq("> > First.\n> >\n> > Second.\n")
    expect(corrected(described_class, source, 'Max' => 0)).to eq(source)
  end

  it 'reports Unicode quote lines at original positions' do
    source = "> 😀 First.\n>\n>\n> Second.\n"
    offense = offenses(described_class, source).fetch(0)
    expect([offense.location.line, offense.location.column]).to eq([3, 0])
    expect(corrected(described_class, source)).to eq("> 😀 First.\n>\n> Second.\n")
  end

  it 'does not merge separate quote containers or inspect quoted code' do
    source = "> First.\n>\n\n> Second.\n>\n>\n> Third.\n> ```\n> code\n>\n>\n> more code\n> ```\n"
    result = corrected(described_class, source)
    expect(offenses(described_class, source).length).to eq(1)
    expect(result).to eq(
      "> First.\n>\n\n> Second.\n>\n> Third.\n> ```\n> code\n>\n>\n> more code\n> ```\n"
    )
  end

  it 'does not interpret quote-looking lines in plain text as Markdown' do
    source = "> First.\n>\n>\n> Second.\n"
    expect(offenses(described_class, source, path: 'example.txt')).to be_empty
    expect(corrected(described_class, source, path: 'example.txt')).to eq(source)
  end

  it 'retains structural minimums when removing excess quote-only blank lines' do
    settings = {
      'Markdown/HeadingBlankLines' => { 'Enabled' => true, 'LinesAbove' => 2, 'LinesBelow' => 2 },
      'Markdown/FenceBlankLines' => { 'Enabled' => true, 'LinesAbove' => 2, 'LinesBelow' => 2 }
    }
    source = "> Préface.\n>\n>\n>\n> # Tête\n>\n>\n>\n> ```ruby\n> puts 'hello'\n> ```\n>\n>\n>\n> Fin.\n"
    expected = "> Préface.\n>\n>\n> # Tête\n>\n>\n> ```ruby\n> puts 'hello'\n> ```\n>\n>\n> Fin.\n"

    expect(corrected(described_class, source, settings: settings)).to eq(expected)
    expect(offenses(described_class, expected, settings: settings)).to be_empty
    expect(corrected(described_class, expected, settings: settings)).to eq(expected)
  end
end
