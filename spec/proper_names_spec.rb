# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Markdown::ProperNames do
  let(:options) { { 'Names' => ['GitHub', 'Ruby', 'C++'] } }

  it 'corrects configured whole names including punctuation' do
    source = "# github and RUBY\n\nUse c++ with github, not githubber or rubylike.\n"
    expected = "# GitHub and Ruby\n\nUse C++ with GitHub, not githubber or rubylike.\n"
    expect(offenses(described_class, source, options).size).to eq(4)
    expect(corrected(described_class, source, options)).to eq(expected)
    expect(offenses(described_class, expected, options)).to be_empty
  end

  it 'does nothing without configured names' do
    expect(offenses(described_class, "github RUBY\n")).to be_empty
  end

  it 'excludes code, links, HTML, escaped text, and front matter by default' do
    source = "---\ntitle: github\n---\n\n`github` [github](https://github.com) <b>github</b> \\Ruby\n\n```ruby\nruby github\n```\n"
    expect(offenses(described_class, source, options)).to be_empty
  end

  it 'optionally checks inline code and code block contents, not fence info strings' do
    source = "`ruby` and ``github``\n\n```ruby\nruby github\n```\n"
    settings = options.merge('CodeBlocks' => true)
    expect(offenses(described_class, source, settings).size).to eq(4)
    expect(corrected(described_class, source, settings)).to eq("`Ruby` and ``GitHub``\n\n```ruby\nRuby GitHub\n```\n")
  end

  it 'ignores multiline code by default and recognizes Unicode word boundaries' do
    source = "Text ``code\nruby github\ncode`` and éruby and githubé.\n"
    expect(offenses(described_class, source, options)).to be_empty
  end

  it 'does not inspect plain text even when selected explicitly' do
    expect(offenses(described_class, "github\n", options, path: 'example.txt')).to be_empty
  end
end
