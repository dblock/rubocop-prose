# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Markdown::HeadingStyle do
  it 'infers the first heading style' do
    expect(offenses(described_class, "# Title\n\n## Detail ##\n").map(&:line)).to eq([3])
  end

  it 'accepts consistent Setext headings' do
    expect(offenses(described_class, "Title\n=====\n\nDetail\n------\n")).to be_empty
  end

  it 'supports explicit ATX style' do
    result = offenses(described_class, "Title\n=====\n\n## Detail\n", { 'EnforcedStyle' => 'atx' })
    expect(result.map(&:line)).to eq([1])
  end

  it 'supports explicit closed and Setext styles' do
    expect(offenses(described_class, "# Title #\n", { 'EnforcedStyle' => 'atx_closed' })).to be_empty
    expect(offenses(described_class, "# Title\n", { 'EnforcedStyle' => 'setext' }).size).to eq(1)
  end

  it 'ignores code and escaped heading syntax' do
    expect(offenses(described_class, "# Title\n\n```\n## Code ##\n```\n\n\\## Literal ##\n")).to be_empty
  end

  it 'does not rewrite heading syntax' do
    source = "# Title\n\n## Detail ##\n"
    expect(corrected(described_class, source)).to eq(source)
  end
end
