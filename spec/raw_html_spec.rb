# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Markdown::RawHtml do
  it 'reports parser-recognized inline and block HTML' do
    source = "<div>\n<b>hello</b>\n</div>\n\nText <i>world</i>.\n"
    expect(offenses(described_class, source).map(&:line)).to eq([1, 2, 5])
  end

  it 'allows configured elements without case sensitivity' do
    expect(offenses(described_class, "Text <br> <b>bold</b>.\n",
                    { 'AllowedElements' => ['BR'] }).size).to eq(1)
  end

  it 'rejects unlisted attributes even alongside allowed attributes' do
    source = <<~HTML
      <img src="chart.png" width="320" data-note="height=200 style=x">
      <IMG SRC='chart.png' HEIGHT="200">
    HTML
    config = { 'AllowedElements' => [{ 'img' => %w[src width height style] }] }

    expect(offenses(described_class, source, config).map(&:line)).to eq([1])
  end

  it 'accepts zero, one, or several listed attributes' do
    source = "<img>\n<img WIDTH='320'>\n<img width=\"320\" height=\"200\">\n"
    config = { 'AllowedElements' => [{ 'img' => %w[width height] }] }

    expect(offenses(described_class, source, config)).to be_empty
  end

  it 'keeps attribute allowlists specific to their element in nested HTML' do
    source = "<div><img src=\"chart.png\" height=\"200\"></div>\n"
    config = { 'AllowedElements' => [{ 'img' => %w[src height] }] }

    expect(offenses(described_class, source, config).map(&:line)).to eq([1])
  end

  it 'retains unrestricted elements alongside attribute allowlists' do
    source = "<br>\n<img src=\"chart.png\">\n<img src=\"chart.png\" width=\"320\" height=\"200\">\n"
    config = {
      'AllowedElements' => ['BR', { 'img' => %w[src width height] }]
    }

    expect(offenses(described_class, source, config)).to be_empty
  end

  it 'lets a plain element name allow tags both with and without attributes' do
    source = "<img>\n<img src=\"chart.png\" width=\"320\">\n"
    config = { 'AllowedElements' => ['IMG', { 'img' => %w[width height] }] }

    expect(offenses(described_class, source, config)).to be_empty
  end

  it 'rejects malformed attribute rules' do
    invalid = [
      { 'img' => { 'Any' => ['width'] } },
      { 'img' => ['width=320'] },
      { 'img' => nil }
    ]
    invalid.each do |entry|
      expect do
        offenses(described_class, "<img>\n", { 'AllowedElements' => [entry] })
      end.to raise_error(RuboCop::ValidationError, %r{Markdown/RawHtml:})
    end
  end

  it 'allows only attribute-free tags with an empty attribute list' do
    source = "<br>\n<br class=\"spacer\">\n"
    config = { 'AllowedElements' => [{ 'br' => [] }] }

    expect(offenses(described_class, source, config).map(&:line)).to eq([2])
  end

  it 'does not parse quoted attribute values as extra attributes' do
    source = "<img alt=\"width=320 > height=200\" src='chart.png'>\n"
    config = { 'AllowedElements' => [{ 'img' => %w[src alt] }] }

    expect(offenses(described_class, source, config)).to be_empty
  end

  it 'enforces attribute allowlists in table cells' do
    source = "| Image |\n| --- |\n| <img width=\"320\"> |\n| <img width=\"320\" height=\"200\"> |\n"
    config = { 'AllowedElements' => [{ 'img' => ['width'] }] }

    expect(offenses(described_class, source, config).map(&:line)).to eq([4])
  end

  it 'does not interpret code, comments, escaped HTML, or autolinks as elements' do
    source = "`<b>` <!-- comment --> <https://example.com> \\<i>\n\n```\n<div>\n```\n"
    expect(offenses(described_class, source)).to be_empty
  end

  it 'maps repeated elements and multiline opening tags' do
    source = "Text <b>one</b> <b>two</b>.\n\n<div\n class=\"x\">\ntext\n</div>\n"
    found = offenses(described_class, source)
    expect(found.map(&:line)).to eq([1, 1, 3])
    expect(found.first(2).map(&:column)).to eq([5, 16])
  end

  it 'ignores front matter and does not autocorrect HTML' do
    source = "---\ntitle: <b>name</b>\n---\n\nText <b>name</b>.\n"
    expect(offenses(described_class, source).size).to eq(1)
    expect(corrected(described_class, source)).to eq(source)
  end

  it 'maps HTML in table cells while ignoring code and autolinks' do
    source = "| a | b |\n| --- | --- |\n| <b>x</b> | `<b>` |\n"
    expect(offenses(described_class, source).map(&:line)).to eq([3])
  end
end
