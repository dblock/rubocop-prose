# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Markdown::ListItemPunctuation do
  it 'requires only allowed punctuation, checking the complete terminal sequence' do
    config = { 'Style' => 'always', 'AllowedPunctuation' => ['.'] }
    source = "- Ready!\n- Ready?\n- Ready…\n- Ready.?\n- Ready?.\n- Ready\n- **Ready.**\n- “Ready.”\n"

    expect(offenses(described_class, source, config).map { |o| o.location.line }).to eq([1, 2, 3, 4, 5, 6])
    expect(corrected(described_class, source, config)).to eq(source)
  end

  it 'restricts punctuated endings in consistent mode without requiring punctuation on unpunctuated lists' do
    config = { 'AllowedPunctuation' => ['.'] }

    expect(offenses(described_class, "- Ready?\n- Finished!\n", config).size).to eq(2)
    expect(offenses(described_class, "- Ready\n- Finished\n", config)).to be_empty
  end

  it 'still forbids all recognized punctuation in never mode regardless of the allowlist' do
    config = { 'Style' => 'never', 'AllowedPunctuation' => ['.'] }

    expect(offenses(described_class, "- Ready?\n- Finished.\n", config).size).to eq(2)
  end

  it 'requires punctuation on every item in always mode, including a single-item list' do
    config = { 'Style' => 'always' }
    source = "- Build the package\n- Run the tests\n- Is it ready?\n"

    expect(offenses(described_class, source, config).map { |o| o.location.line }).to eq([1, 2])
    expect(offenses(described_class, "- Build the package\n", config).first.message)
      .to include('End list items with terminal punctuation.')
    expect(corrected(described_class, source, config)).to eq(source)
  end

  it 'forbids punctuation on every item in never mode' do
    config = { 'Style' => 'never' }
    source = "- **Build the package.**\n- “Run the tests!”\n- Check results\n"

    expect(offenses(described_class, source, config).map { |o| o.location.line }).to eq([1, 2])
    expect(offenses(described_class, "- Ready?\n", config).first.message)
      .to include('Do not end list items with terminal punctuation.')
    expect(offenses(described_class, "- Ready\n", config)).to be_empty
  end

  it 'applies explicit styles independently to nested lists while retaining ambiguous-list exclusions' do
    config = { 'Style' => 'always' }
    source = "- Parent\n  - Build the package\n  - Run the tests.\n- Parent\n"
    ambiguous = "- Build the package.\n\n  More details.\n- Run the tests\n"

    expect(offenses(described_class, source, config).map { |o| o.location.line }).to eq([2])
    expect(offenses(described_class, ambiguous, config)).to be_empty
  end

  it 'reports sibling items that differ in terminal punctuation presence' do
    source = "- Build the package.\n- Run the tests\n"

    offenses = offenses(described_class, source)

    expect(offenses.size).to eq(1)
    expect(offenses.first.message).to include('consistently')
    expect(corrected(described_class, source)).to eq(source)
  end

  it 'compares punctuation presence rather than exact punctuation characters' do
    source = "- Build the package!\n- Is it ready?\n"

    expect(offenses(described_class, source)).to be_empty
  end

  it 'recognizes punctuation inside inline markup and before closing quotes' do
    source = "- **Build the package.**\n- “Run the tests.”\n"

    expect(offenses(described_class, source)).to be_empty
    expect(offenses(described_class, "- [Build the package.](https://example.com)\n- Run tests\n")).not_to be_empty
  end

  it 'checks nested lists independently' do
    source = "- Parent\n  - Build the package.\n  - Run the tests\n- Parent\n"

    offenses = offenses(described_class, source)

    expect(offenses.size).to eq(1)
    expect(offenses.first.location.line).to eq(3)
  end

  it 'skips lists with code or multiple paragraphs in an item' do
    code = "- Build the package.\n- ```\n  run tests\n  ```\n"
    paragraphs = "- Build the package.\n\n  More details.\n- Run the tests\n"

    expect(offenses(described_class, code)).to be_empty
    expect(offenses(described_class, paragraphs)).to be_empty
  end

  it 'does not report consistent lists or inspect plain text files' do
    expect(offenses(described_class, "- Build the package\n- Run the tests\n")).to be_empty
    expect(offenses(described_class, "- Build the package.\n- Run the tests\n", path: 'example.txt')).to be_empty
  end
end
