# frozen_string_literal: true

RSpec.describe 'Plain-text prose policies' do
  let(:formatter) { RuboCop::Cop::Prose::MaxLength }
  let(:whitespace) { RuboCop::Cop::Text::TrailingWhitespace }

  it 'trims all text whitespace, including inside literal metadata and fences' do
    source = "---  \nvalue: text \t\n---\n```\nline  \n```\n"
    expect(corrected(whitespace, source, path: 'example.txt')).to eq(
      "---\nvalue: text\n---\n```\nline\n```\n"
    )
    expect(corrected(whitespace, "line  \n", path: 'example.md')).to eq("line  \n")
    expect(corrected(RuboCop::Cop::Markdown::TrailingWhitespace, "line  \n")).to eq("line  \n")
  end

  it 'applies shared blank-line and final-newline rules to text without Markdown exemptions' do
    source = "```\n\n\nliteral\n```\n"
    cop = RuboCop::Cop::Prose::MultipleBlankLines
    expect(corrected(cop, source, path: 'example.txt')).to eq("```\n\nliteral\n```\n")
    expect(corrected(cop, source)).to eq(source)
    expect(corrected(RuboCop::Cop::Prose::TrailingNewline, 'text', path: 'example.txt')).to eq("text\n")
  end

  it 'does not let Markdown-specific cops inspect text even when selected explicitly' do
    cops = RuboCop::Cop::Registry.global.select { |cop| cop.department.to_s == 'Markdown' }
    source = "# Title\n### Details.\n\n```\ntext\n```\n\n[Missing][missing]\n\n![](image.png) \t\n"
    expect(offenses(cops, source, path: 'example.txt')).to be_empty
  end

  it 'does not apply Markdown configuration to literal text' do
    source = "---\ntitle: First\n...\n"
    expect(corrected(formatter, source, { 'Max' => false }, path: 'example.txt',
                                                            settings: { 'Markdown' => { 'IgnoreFrontMatter' => 'yes' } })).to eq(
                                                              "--- title: First ...\n"
                                                            )
  end

  it 'does not let shared or format-specific document cops inspect Ruby' do
    cops = [formatter, whitespace, RuboCop::Cop::Markdown::HeadingPunctuation]
    expect(offenses(cops, "puts 1 \t\n", path: 'example.rb')).to be_empty
  end
end
