# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Prose::FenceLanguage do
  it 'reports missing languages without guessing a correction' do
    source = "```\nexample\n```\n"
    expect(offenses(described_class, source).size).to eq(1)
    expect(corrected(described_class, source)).to eq(source)
  end

  it 'checks an explicit case-sensitive allowlist' do
    source = "~~~ruby\nputs 1\n~~~\n\n~~~Ruby\nputs 2\n~~~\n"
    expect(offenses(described_class, source, 'AllowedLanguages' => ['ruby']).size).to eq(1)
  end

  it 'recognizes languages in list and quote containers' do
    expect(offenses(described_class, "> - ```sh\n>   echo hi\n>   ```\n")).to be_empty
  end

  it 'ignores indented code and fence-looking front matter' do
    expect(offenses(described_class, "---\nexample: ```\n---\n\n    example\n")).to be_empty
  end
end
