# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Prose::MaxLength, 'document line-length contexts' do
  it 'reports heading source without rewriting its structure' do
    source = "# A very long heading\n"
    expect(offenses(described_class, source, 'HeadingMax' => 10).map(&:line)).to eq([1])
    expect(corrected(described_class, source, 'HeadingMax' => 10)).to eq(source)
    expect(offenses(described_class, source, 'Max' => 5, 'Headings' => false)).to be_empty
  end

  it 'can check code using its own limit while leaving code untouched' do
    source = "```ruby\nputs 'long code'\n```\n"
    expect(offenses(described_class, source, 'Max' => 5)).to be_empty
    options = { 'CodeBlocks' => true, 'CodeBlockMax' => 8 }
    expect(offenses(described_class, source, options).map(&:line)).to eq([2])
    expect(corrected(described_class, source, options)).to eq(source)
  end

  it 'optionally reports table source including delimiters without reflowing cells' do
    source = "| name | value |\n| --- | --- |\n| a | b |\n"
    expect(offenses(described_class, source, 'Max' => 10)).to be_empty
    expect(offenses(described_class, source, 'Max' => 10, 'Tables' => true).map(&:line)).to eq([1, 2])
    expect(corrected(described_class, source, 'Max' => 10, 'Tables' => true)).to eq(source)
  end

  it 'offers relaxed or strict URL-only line reporting' do
    source = "https://example.com/a-long-address\n"
    expect(offenses(described_class, source, 'Max' => 10)).to be_empty
    expect(offenses(described_class, source, 'Max' => 10, 'IgnoreURLs' => false).length).to eq(1)
  end
end
