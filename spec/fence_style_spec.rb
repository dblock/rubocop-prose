# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Markdown::FenceStyle do
  it 'migrates the released EnforcedStyle setting to Style' do
    config = RuboCop::Config.new(
      { 'Markdown/FenceStyle' => { 'EnforcedStyle' => 'backtick' } }, '.rubocop.yml'
    )
    expect { RuboCop::ConfigObsoletion.new(config).reject_obsolete! }
      .to raise_error(RuboCop::ValidationError, /obsolete parameter `EnforcedStyle`.*Style/m)
  end

  it 'uses the first fence style and is idempotent' do
    source = "```ruby\nx\n```\n\n~~~sh\npwd\n~~~\n"
    expect(offenses(described_class, source).size).to eq(1)
    result = corrected(described_class, source)
    expect(result).to eq("```ruby\nx\n```\n\n```sh\npwd\n```\n")
    expect(offenses(described_class, result)).to be_empty
  end

  it 'preserves container prefixes and language metadata' do
    expect(corrected(described_class, "> - ```ruby\n>   x\n>   ```\n", 'Style' => 'tilde')).to eq("> - ~~~ruby\n>   x\n>   ~~~\n")
  end

  it 'lengthens new fences to avoid delimiters in their content' do
    expect(corrected(described_class, "~~~\n```\n~~~\n", 'Style' => 'backtick')).to eq("````\n```\n````\n")
  end

  it 'ignores indented code and front matter' do
    expect(offenses(described_class, "---\nx: ~~~\n---\n\n    ~~~\n", 'Style' => 'backtick')).to be_empty
  end
end
