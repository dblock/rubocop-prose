# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Markdown::HeadingStyle do
  it 'migrates the released EnforcedStyle setting to Style' do
    config = RuboCop::Config.new(
      { 'Markdown/HeadingStyle' => { 'EnforcedStyle' => 'atx' } }, '.rubocop.yml'
    )
    expect { RuboCop::ConfigObsoletion.new(config).reject_obsolete! }
      .to raise_error(RuboCop::ValidationError, /obsolete parameter `EnforcedStyle`.*Style/m)
  end

  it 'infers the first heading style' do
    expect(offenses(described_class, "# Title\n\n## Detail ##\n").map(&:line)).to eq([3])
  end

  it 'accepts consistent Setext headings' do
    expect(offenses(described_class, "Title\n=====\n\nDetail\n------\n")).to be_empty
  end

  it 'supports explicit ATX style' do
    result = offenses(described_class, "Title\n=====\n\n## Detail\n", { 'Style' => 'atx' })
    expect(result.map(&:line)).to eq([1])
  end

  it 'supports explicit closed and Setext styles' do
    expect(offenses(described_class, "# Title #\n", { 'Style' => 'atx_closed' })).to be_empty
    expect(offenses(described_class, "# Title\n", { 'Style' => 'setext' }).size).to eq(1)
  end

  it 'ignores code and escaped heading syntax' do
    expect(offenses(described_class, "# Title\n\n```\n## Code ##\n```\n\n\\## Literal ##\n")).to be_empty
  end

  it 'does not rewrite heading syntax' do
    source = "# Title\n\n## Detail ##\n"
    expect(corrected(described_class, source)).to eq(source)
  end
end
