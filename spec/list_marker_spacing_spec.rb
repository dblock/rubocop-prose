# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Markdown::ListMarkerSpacing do
  it 'corrects simple item spacing and is idempotent' do
    source = "-  one\n- two\n"
    expect(offenses(described_class, source).size).to eq(1)
    result = corrected(described_class, source)
    expect(result).to eq("- one\n- two\n")
    expect(offenses(described_class, result)).to be_empty
  end

  it 'uses configured ordered single-line spacing' do
    expect(offenses(described_class, "1.  one\n2.  two\n", 'OrderedSingle' => 2)).to be_empty
  end

  it 'reports multiline spacing without shifting continuation blocks' do
    source = "-  one\n   continuation\n"
    expect(offenses(described_class, source).size).to eq(1)
    expect(corrected(described_class, source)).to eq(source)
  end

  it 'ignores code and escaped markers' do
    expect(offenses(described_class, "\\-  text\n\n```\n-  code\n```\n")).to be_empty
  end
end
