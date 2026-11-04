# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Markdown::UnclosedFencedCodeBlock do
  it 'reports the opening fence of an EOF-terminated block without correcting it' do
    source = "```ruby\nputs 'hello'\n"
    offense = offenses(described_class, source).fetch(0)

    expect([offense.location.line, offense.location.column]).to eq([1, 0])
    expect(corrected(described_class, source)).to eq(source)
  end

  it 'matches delimiter character and length rather than code-content runs' do
    source = "````ruby\n```\n~~~\n"
    expect(offenses(described_class, source).size).to eq(1)
    expect(offenses(described_class, "~~~ruby\n````\n~~~\n")).to be_empty
    expect(offenses(described_class, "```ruby\nputs 1\n````\n")).to be_empty
  end

  it 'recognizes nested containers and reports the original Unicode location' do
    source = "# Café\n\n> - ```ruby\n>   puts '💎'\n"
    offense = offenses(described_class, source).fetch(0)

    expect([offense.location.line, offense.location.column]).to eq([3, 4])
    expect(offenses(described_class, "> - ```ruby\n>   puts 1\n>   ```\n")).to be_empty
  end

  it 'does not report fences in front matter or indented code' do
    source = "---\n```ruby\n---\n\n    ```ruby\n    puts 1\n"
    expect(offenses(described_class, source)).to be_empty
  end

  it 'does not accept a closer from a different container' do
    expect(offenses(described_class, "> ```ruby\n> - ```\n").size).to eq(1)
  end

  it 'does not report Markdown rules for text files' do
    expect(offenses(described_class, "```ruby\nputs 1\n", path: 'example.txt')).to be_empty
  end
end
