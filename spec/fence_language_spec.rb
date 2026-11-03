# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Markdown::FenceLanguage do
  it 'reports missing languages without guessing a correction' do
    source = "```\nexample\n```\n"
    expect(offenses(described_class, source).size).to eq(1)
    expect(corrected(described_class, source)).to eq(source)
  end

  it 'checks an explicit case-sensitive allowlist' do
    source = "~~~ruby\nputs 1\n~~~\n\n~~~Ruby\nputs 2\n~~~\n"
    expect(offenses(described_class, source, 'AllowedLanguages' => ['ruby']).size).to eq(1)
  end

  it 'rejects only disallowed names while still requiring a language' do
    source = "~~~js\nexample\n~~~\n\n~~~JS\nexample\n~~~\n\n```ruby\nexample\n```\n\n```\nexample\n```\n"
    result, rewritten = investigate(described_class, source, 'DisallowedLanguages' => ['js'])

    expect(result.map { |offense| offense.location.source }).to eq(['~~~js', '```'])
    expect(result.first.message).to include("disallowed fence language 'js'")
    expect(result.last.message).to include('Specify a language')
    expect(rewritten).to eq(source)
  end

  it 'checks disallowed languages in containers but not metadata or indented code' do
    source = "---\n```js\n---\n\n> - ```js\n>   echo hi\n>   ```\n\n    ```js\n"
    result = offenses(described_class, source, 'DisallowedLanguages' => ['js'])

    expect(result.map { |offense| offense.location.source }).to eq(['> - ```js'])
  end

  it 'rejects conflicting allowlists and disallowlists' do
    expect do
      offenses(described_class, "```ruby\nexample\n```\n",
               'AllowedLanguages' => ['ruby'], 'DisallowedLanguages' => ['js'])
    end.to raise_error(RuboCop::ValidationError, /configure AllowedLanguages or DisallowedLanguages, not both/)
  end

  it 'rejects malformed language lists explicitly' do
    [
      { 'AllowedLanguages' => 'ruby' },
      { 'DisallowedLanguages' => nil },
      { 'DisallowedLanguages' => 'js' },
      { 'DisallowedLanguages' => [42] }
    ].each do |options|
      expect do
        offenses(described_class, "```ruby\nexample\n```\n", options)
      end.to raise_error(RuboCop::ValidationError, /must be an array of language names/)
    end
  end

  it 'recognizes languages in list and quote containers' do
    expect(offenses(described_class, "> - ```sh\n>   echo hi\n>   ```\n")).to be_empty
  end

  it 'ignores indented code and fence-looking front matter' do
    expect(offenses(described_class, "---\nexample: ```\n---\n\n    example\n")).to be_empty
  end
end
