# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Markdown::HeadingCapitalization do
  it 'corrects lowercase initials in ATX and Setext headings' do
    source = "## installing the package ##\n\ngetting Started\n---------------\n\nUsing the API\n=============\n"
    found, result = investigate(described_class, source, 'EnforcedStyle' => 'initial_capital')
    expect(found.map(&:line)).to eq([1, 3])
    expect(found.map(&:message)).to all(include('first prose letter'))
    expect(result).to eq("## Installing the package ##\n\nGetting Started\n---------------\n\nUsing the API\n=============\n")
  end

  it 'ignores inline delimiters and link destinations when finding the first letter' do
    source = "# ***installing*** the package\n\n## [installing](https://Example.org) packages\n\n## &eacute;lan\n\n## \\*installing\\*\n"
    expect(offenses(described_class, source).map(&:line)).to eq([1, 3, 5, 7])
  end

  it 'reports lowercase code and quoted openings without changing their literal contents' do
    source = "# `excalc` usage\n\n## **`excalc`** usage\n\n`excalc` usage\n--------------\n\n# \"excalc\" usage\n\n# `Excalc` usage\n\n# using `excalc`\n"
    expect(offenses(described_class, source, 'EnforcedStyle' => 'initial_capital').map(&:line)).to eq([1, 3, 5, 8, 12])
    expect(corrected(described_class, source, 'EnforcedStyle' => 'initial_capital')).to eq(source)
    expect(offenses(described_class, "# `excalc` usage\n", 'EnforcedStyle' => 'title_case').map(&:line)).to eq([1])
  end

  it 'preserves mixed-case leading brands and does not check the remaining words' do
    source = "# eBay usage\n\n## iOS support\n\n## macOS installation\n\n## Installing the PACKAGE with github\n"
    expect(offenses(described_class, source, 'EnforcedStyle' => 'initial_capital')).to be_empty
  end

  it 'can require uppercase initials for mixed-case words in either style' do
    source = "# macOS Support\n\n# Using macOS\n\n# Using API\n"
    options = { 'PreserveMixedCase' => false, 'EnforcedStyle' => 'initial_capital' }
    expect(offenses(described_class, source, options).map(&:line)).to eq([1])
    expect(offenses(described_class, source, options.merge('EnforcedStyle' => 'title_case')).map(&:line)).to eq([1, 3])
    options.merge!('EnforcedStyle' => 'title_case', 'IgnoredWords' => ['macOS'])
    expect(offenses(described_class, source, options)).to be_empty
  end

  it 'rejects nonboolean mixed-case configuration' do
    expect do
      offenses(described_class, "# Heading\n", 'PreserveMixedCase' => 'false')
    end.to raise_error(RuboCop::ValidationError, /PreserveMixedCase/)
  end

  it 'honors native suppression directives for intentional lowercase headings' do
    source = <<~MARKDOWN
      <!-- # rubocop:disable Markdown/HeadingCapitalization -->
      # npm usage

      npm usage
      ---------
      <!-- # rubocop:enable Markdown/HeadingCapitalization -->

      # npm usage
    MARKDOWN
    expect(offenses(described_class, source).map(&:line)).to eq([8])
  end

  it 'does not exempt canonical ProperNames spellings' do
    settings = { 'Markdown/ProperNames' => { 'Names' => ['npm'], 'Enabled' => true } }
    source = "# npm usage\n\nnpm usage\n---------\n"
    expect(offenses(described_class, source, settings: settings).map(&:line)).to eq([1, 3])
  end

  it 'checks lowercase initials after numeric and punctuation prefixes' do
    source = "# 123 installing\n\n# 1password usage\n\n# 11password usage\n\n# «npm» usage\n\n# _npmish_ usage\n"
    expect(offenses(described_class, source).map(&:line)).to eq([1, 3, 5, 7, 9])
  end

  it 'checks Unicode initials in containers and reports original source locations' do
    source = "> ## «élan» and Ruby\n\n- ## installing\n"
    found = offenses(described_class, source)
    expect(found.map(&:line)).to eq([1, 3])
    expect(found.first.location.source).to eq('> ## «élan» and Ruby')
  end

  it 'accepts uppercase, uncased, empty, and punctuation-only headings' do
    source = "# Élan\n\n# 中文\n\n# 123 Installing\n\n# !!!\n\n#\n"
    expect(offenses(described_class, source)).to be_empty
  end

  it 'does not guess at opaque leading HTML or image content' do
    source = "# <code>excalc</code> usage\n\n## ![logo](logo.png) usage\n"
    expect(offenses(described_class, source)).to be_empty
  end

  it 'ignores prose, code blocks, front matter, and plain-text files' do
    source = "---\ntitle: installing\n---\n\ninstalling the package\n\n```markdown\n# installing\n```\n"
    expect(offenses(described_class, source)).to be_empty
    expect(offenses(described_class, "# installing\n", path: 'example.txt')).to be_empty
  end

  it 'requires title-case major words and lowercase internal minor words by default' do
    source = "# Getting started with the API\n\n# Getting Started With The API\n\n# Getting Started with the API\n"
    expect(offenses(described_class, source).map(&:line)).to eq([1, 3])
    expect(corrected(described_class, source)).to eq(
      "# Getting Started with the API\n\n# Getting Started with the API\n\n# Getting Started with the API\n"
    )
  end

  it 'capitalizes first and last minor words and checks Setext markup' do
    source = "# the API and\n\n# The API And\n\n*Getting* [started](guide.html) with the API\n------------------------------------------\n"
    expect(offenses(described_class, source, 'EnforcedStyle' => 'title_case').map(&:line)).to eq([1, 5])
  end

  it 'preserves brands, acronyms, Unicode and uncased words in title case' do
    source = "# Getting Started with macOS and the API\n\n# Élan with 中文\n\n# Don't Re-enter the API\n"
    expect(offenses(described_class, source, 'EnforcedStyle' => 'title_case')).to be_empty
  end

  it 'skips title-case headings containing opaque inline content' do
    source = "# Using `excalc` with ruby\n\n# Using ![logo](logo.png) with ruby\n"
    expect(offenses(described_class, source, 'EnforcedStyle' => 'title_case')).to be_empty
  end

  it 'rejects unsupported capitalization styles' do
    expect do
      offenses(described_class, "# Heading\n", 'EnforcedStyle' => 'sentence_case')
    end.to raise_error(RuboCop::ValidationError, /EnforcedStyle/)
  end

  it 'replaces default minor words and matches them case-insensitively' do
    options = { 'EnforcedStyle' => 'title_case', 'MinorWords' => ['THE'] }
    source = "# Getting Started with the API\n\n# Getting Started With the API\n"
    expect(offenses(described_class, source, options).map(&:line)).to eq([1])
  end

  it 'supports no minor words and gives ignored words precedence' do
    source = "# Getting Started with the API\n"
    options = { 'EnforcedStyle' => 'title_case', 'MinorWords' => [] }
    expect(offenses(described_class, source, options).size).to eq(1)
    expect(offenses(described_class, "# Using The API\n",
                    'EnforcedStyle' => 'title_case', 'MinorWords' => ['the'], 'IgnoredWords' => ['The'])).to be_empty
  end

  it 'rejects invalid minor-word configuration' do
    expect do
      offenses(described_class, "# Heading\n", 'MinorWords' => ['two words'])
    end.to raise_error(RuboCop::ValidationError, /MinorWords/)
  end

  it 'ignores exact words in both styles without exempting other words' do
    options = { 'IgnoredWords' => %w[macOS npm], 'EnforcedStyle' => 'initial_capital' }
    source = "# **npm** usage\n\n# npmlike usage\n"
    expect(offenses(described_class, source, options).map(&:line)).to eq([3])

    source = "# Using npm on macOS\n\n# Using npmlike on macOS\n\n# Getting started with npm\n"
    expect(offenses(described_class, source, options.merge('EnforcedStyle' => 'title_case')).map(&:line)).to eq([3, 5])
  end

  it 'matches ignored words case-sensitively including minor words' do
    options = { 'EnforcedStyle' => 'title_case', 'IgnoredWords' => ['The'] }
    source = "# Using The API\n\n# Using THE API\n"
    expect(offenses(described_class, source, options).map(&:line)).to eq([3])
  end

  it 'rejects phrases and non-array ignored words' do
    ['npm', ['getting started'], [nil]].each do |words|
      expect do
        offenses(described_class, "# Heading\n", 'IgnoredWords' => words)
      end.to raise_error(RuboCop::ValidationError, /IgnoredWords/)
    end
  end

  it 'corrects Unicode and container headings without changing markup or underlines' do
    source = "> ## **élan with ruby** ##\n\n- ## getting started\n\ngetting started\n---------------\n"
    expected = "> ## **Élan with Ruby** ##\n\n- ## Getting Started\n\nGetting Started\n---------------\n"
    result = corrected(described_class, source)
    expect(result).to eq(expected)
    expect(corrected(described_class, result)).to eq(result)
  end

  it 'preserves ignored words and mixed-case policy during correction' do
    options = { 'PreserveMixedCase' => false, 'IgnoredWords' => ['npm'] }
    source = "# using npm with macOS\n"
    expect(corrected(described_class, source, options)).to eq("# Using npm with MacOS\n")
  end

  it 'withholds correction for split markup, links and encoded entities' do
    source = "# getting **started**\n\n# [getting started](getting-started.html)\n\n# &#103;etting started\n"
    expect(offenses(described_class, source).size).to eq(3)
    expect(corrected(described_class, source)).to eq(source)
  end

  it 'does not rewrite identifiers or URLs in title-case headings' do
    source = "# Using foo_bar\n\n# https://example.com\n"
    expect(corrected(described_class, source, 'EnforcedStyle' => 'title_case')).to eq(source)
  end

  it 'is registered and disabled by default' do
    expect(RuboCop::Cop::Registry.global.find_by_cop_name('Markdown/HeadingCapitalization')).to eq(described_class)
    expect(RuboCop::Prose.default_configuration.fetch('Markdown/HeadingCapitalization')).to include(
      'Enabled' => false, 'EnforcedStyle' => 'title_case'
    )
  end
end
