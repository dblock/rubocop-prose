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

  it 'uses the same fixed spacing for ordered and unordered lists' do
    source = "1.  one\n2.  two\n\n-  three\n-  four\n"
    expect(offenses(described_class, source, 'MinSpaces' => 2)).to be_empty
    expect(corrected(described_class, "1. one\n\n- two\n", 'MinSpaces' => 2)).to eq("1.  one\n\n-  two\n")
  end

  it 'reports multiline spacing without shifting continuation blocks' do
    source = "-  one\n   continuation\n"
    expect(offenses(described_class, source).size).to eq(1)
    expect(corrected(described_class, source)).to eq(source)
  end

  it 'ignores code and escaped markers' do
    expect(offenses(described_class, "\\-  text\n\n```\n-  code\n```\n")).to be_empty
  end

  it 'aligns ordered sibling text across digit widths and stabilizes' do
    source = "8. Eight\n9. Nine\n10. Ten\n"
    options = { 'EnforcedStyle' => 'aligned' }
    expect(offenses(described_class, source, options).size).to eq(2)
    result = corrected(described_class, source, options)
    expect(result).to eq("8.  Eight\n9.  Nine\n10. Ten\n")
    expect(offenses(described_class, result, options)).to be_empty
  end

  it 'uses actual marker widths across wider transitions' do
    source = "98. α\n99. β\n100. γ\n"
    options = { 'EnforcedStyle' => 'aligned' }
    result = corrected(described_class, source, options)
    expect(result).to eq("98.  α\n99.  β\n100. γ\n")
    expect(offenses(described_class, result, options)).to be_empty
  end

  it 'keeps fixed ordered spacing as the default' do
    source = "9. Nine\n10. Ten\n"
    expect(offenses(described_class, source)).to be_empty
    expect(corrected(described_class, "9.  Nine\n10. Ten\n")).to eq(source)
  end

  it 'checks multiline alignment without rewriting continuation lines or nested content' do
    source = "9. Nine\n   continuation\n\n   - child\n10. Ten\n"
    options = { 'EnforcedStyle' => 'aligned' }
    expect(offenses(described_class, source, options).size).to eq(1)
    expect(corrected(described_class, source, options)).to eq(source)
  end

  it 'uses the same aligned policy for single-line and multiline lists' do
    source = "9.  Nine\n    continuation\n10. Ten\n\nText.\n\n9.  Nine\n10. Ten\n"
    expect(offenses(described_class, source, 'EnforcedStyle' => 'aligned')).to be_empty
  end

  it 'keeps nested lists and blockquote lists independent' do
    source = "9. Nine\n   1. child\n   2. child\n10. Ten\n\n> 1. quote\n> 2. quote\n"
    options = { 'EnforcedStyle' => 'aligned' }
    expect(offenses(described_class, source, options).size).to eq(1)
    expect(corrected(described_class, source, options)).to eq(source)
  end

  it 'corrects blockquote spacing without changing container prefixes or Unicode text' do
    source = "> 9. café\n> 10. ten\n"
    expect(corrected(described_class, source, 'EnforcedStyle' => 'aligned'))
      .to eq("> 9.  café\n> 10. ten\n")
  end

  it 'does not align separate lists against one another' do
    source = "1. one\n2. two\n\nText.\n\n100. hundred\n101. next\n"
    expect(offenses(described_class, source, 'EnforcedStyle' => 'aligned')).to be_empty
  end

  it 'reports gaps wider than four spaces without changing Markdown interpretation' do
    source = "1. one\n10000. wide\n"
    options = { 'EnforcedStyle' => 'aligned' }
    expect(offenses(described_class, source, options).size).to eq(1)
    expect(corrected(described_class, source, options)).to eq(source)
  end

  it 'aligns using the configured minimum padding and stabilizes' do
    options = { 'EnforcedStyle' => 'aligned', 'MinSpaces' => 2 }
    source = "8. Eight\n9. Nine\n10. Ten\n\n- bullet\n"
    expect(offenses(described_class, source, options).size).to eq(4)
    result = corrected(described_class, source, options)
    expect(result).to eq("8.   Eight\n9.   Nine\n10.  Ten\n\n-  bullet\n")
    expect(offenses(described_class, result, options)).to be_empty
  end

  it 'checks minimum padding for multiline lists without rewriting continuations' do
    options = { 'EnforcedStyle' => 'aligned', 'MinSpaces' => 2 }
    source = "9.  Nine\n    continuation\n10.  Ten\n"
    expect(offenses(described_class, source, options).size).to eq(1)
    expect(corrected(described_class, source, options)).to eq(source)
  end

  it 'leaves computed padding over four spaces report-only' do
    options = { 'EnforcedStyle' => 'aligned', 'MinSpaces' => 4 }
    source = "9. Nine\n10.    Ten\n"
    expect(offenses(described_class, source, options).size).to eq(1)
    expect(corrected(described_class, source, options)).to eq(source)
  end

  it 'rejects invalid styles and minimum spacing' do
    [
      { 'EnforcedStyle' => 'unknown' }, { 'MinSpaces' => 0 },
      { 'MinSpaces' => '2' }, { 'MinSpaces' => nil }, { 'MinSpaces' => 1.5 }
    ].each do |options|
      expect { offenses(described_class, "1. one\n", options) }.to raise_error(RuboCop::ValidationError)
    end
  end

  it 'rejects every legacy setting with migration guidance even when values agree' do
    %w[OrderedSingle OrderedMulti UnorderedSingle UnorderedMulti].each do |key|
      config = RuboCop::Config.new({ 'Markdown/ListMarkerSpacing' => { key => 1 } }, '.rubocop.yml')
      expect { RuboCop::ConfigObsoletion.new(config).reject_obsolete! }
        .to raise_error(RuboCop::ValidationError, /#{key}.*Use EnforcedStyle.*MinSpaces/m)
    end
    config = RuboCop::Config.new(
      { 'Markdown/ListMarkerSpacing' => { 'OrderedSingle' => 1, 'UnorderedMulti' => 3 } }, '.rubocop.yml'
    )
    expect do
      RuboCop::ConfigObsoletion.new(config).reject_obsolete!
    end.to raise_error(RuboCop::ValidationError, /Different legacy spacing values cannot be preserved/)
  end
end
