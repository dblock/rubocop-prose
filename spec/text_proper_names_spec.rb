# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Text::ProperNames do
  let(:options) { { 'Names' => ['GitHub', 'Ruby', 'C++'] } }

  it 'checks Markdown-like syntax literally in plain text without parsing it' do
    source = "`github` [github](https://github.com/github)\nhttps://github.com/github\n```ruby\ngithub\n```\n"
    expected = "`GitHub` [GitHub](https://GitHub.com/GitHub)\nhttps://GitHub.com/GitHub\n```Ruby\nGitHub\n```\n"
    expect(corrected(described_class, source, options, path: 'example.txt')).to eq(expected)
  end

  it 'uses character-based locations, whole-word boundaries, and literal punctuation' do
    source = "😀 github and c++; éruby and githubé stay unchanged.\n"
    expected = "😀 GitHub and C++; éruby and githubé stay unchanged.\n"
    found = offenses(described_class, source, options, path: 'example.txt')
    expect(found.map(&:column)).to eq([2, 13])
    expect(corrected(described_class, source, options, path: 'example.txt')).to eq(expected)
    expect(offenses(described_class, expected, options, path: 'example.txt')).to be_empty
  end

  it 'does nothing without configured names' do
    expect(offenses(described_class, "github RUBY\n", path: 'example.txt')).to be_empty
  end

  it 'does not inspect Markdown even when selected explicitly' do
    expect(offenses(described_class, "github\n", options)).to be_empty
  end
end
