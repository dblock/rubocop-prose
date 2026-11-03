# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Markdown::BlockquoteSpacing do
  it 'corrects extra spaces at each quote level' do
    source = ">  >  words\n"
    expect(offenses(described_class, source).size).to eq(2)
    result = corrected(described_class, source)
    expect(result).to eq("> > words\n")
    expect(offenses(described_class, result)).to be_empty
  end

  it 'preserves indentation used by lists and code' do
    source = "> - parent\n>   - child\n>\n>     code\n"
    expect(offenses(described_class, source)).to be_empty
  end

  it 'ignores escaped quotes and permits missing spaces and empty quote lines' do
    expect(offenses(described_class, "\\>  text\n\n>text\n>   \n")).to be_empty
  end

  it 'ignores quote-looking text in an HTML block' do
    expect(offenses(described_class, "<div>\n>  not a quote\n</div>\n")).to be_empty
  end
end
