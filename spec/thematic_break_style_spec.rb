# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Prose::ThematicBreakStyle do
  it 'uses the first thematic break in consistent mode' do
    source = "***\n\n- - -\n"
    expect(offenses(described_class, source).size).to eq(1)
    expect(corrected(described_class, source)).to eq("***\n\n***\n")
  end

  it 'uses the configured literal spelling and preserves container prefixes' do
    source = "> ***\n\n  ___\n"
    expected = "> - - -\n\n  - - -\n"
    expect(corrected(described_class, source, { 'Style' => '- - -' })).to eq(expected)
    expect(offenses(described_class, expected, { 'Style' => '- - -' })).to be_empty
  end

  it 'does not treat setext headings, front matter, or code as thematic breaks' do
    source = "---\ntitle: example\n---\n\nHeading\n---\n\n```\n***\n```\n\n    ___\n"
    expect(offenses(described_class, source, { 'Style' => '---' })).to be_empty
  end

  it 'ignores trailing whitespace when comparing breaks' do
    expect(offenses(described_class, "***  \n\n***\n")).to be_empty
  end

  it 'does not infer a thematic break inside a parser-recognized paragraph' do
    source = "paragraph\n***\n"
    expect(offenses(described_class, source, { 'Style' => '---' })).to be_empty
    expect(corrected(described_class, source, { 'Style' => '---' })).to eq(source)
  end
end
