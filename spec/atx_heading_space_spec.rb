# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Markdown::AtxHeadingSpace do
  it 'reports missing opening whitespace' do
    expect(offenses(described_class, "##Résumé\n").map(&:line)).to eq([1])
  end

  it 'accepts normal, empty and tab-separated headings' do
    expect(offenses(described_class, "# Title\n\n##\n\n###\tDetail\n")).to be_empty
  end

  it 'recognizes simple container prefixes' do
    expect(offenses(described_class, "> ##Title\n\n- ###Detail\n").map(&:line)).to eq([1, 3])
  end

  it 'ignores code, front matter, escapes and excessive hash runs' do
    source = "---\ntitle: '#Ignored'\n---\n```\n#Code\n```\n\n    #Code\n\n\\#Literal\n\n#######Literal\n"
    expect(offenses(described_class, source)).to be_empty
  end

  it 'does not turn text into a heading' do
    expect(corrected(described_class, "#hashtag\n")).to eq("#hashtag\n")
  end
end
