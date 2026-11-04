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

  it 'corrects missing separators at each nested quote level' do
    source = ">Quoted text.\n>>Nested text.\n"
    expect(offenses(described_class, source).size).to eq(3)

    result = corrected(described_class, source)
    expect(result).to eq("> Quoted text.\n> > Nested text.\n")
    expect(offenses(described_class, result)).to be_empty
  end

  it 'preserves list and code indentation while correcting a quote before a list' do
    source = ">- parent\n>   - child\n>\n>     code\n"
    expect(corrected(described_class, source)).to eq("> - parent\n>   - child\n>\n>     code\n")
  end

  it 'maps missing separators to original Unicode source locations' do
    source = "> 😀\n> >é\n"
    offense = offenses(described_class, source).fetch(0)

    expect([offense.location.line, offense.location.column]).to eq([2, 2])
    expect(corrected(described_class, source)).to eq("> 😀\n> > é\n")
  end

  it 'ignores escaped, literal, code, HTML, and empty quote markers' do
    source = "\\>  text\n\n>   \n>>\nText >text\n```\n>text\n```\n<div>\n>  not a quote\n</div>\n"
    expect(offenses(described_class, source)).to be_empty
  end

  it 'is enabled by default' do
    settings = RuboCop::Prose.default_configuration['Markdown/BlockquoteSpacing']
    expect(settings['Enabled']).to be(true)
  end
end
