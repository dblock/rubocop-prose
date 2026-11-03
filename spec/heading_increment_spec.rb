# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Prose::HeadingIncrement do
  it 'reports a skipped level' do
    result = offenses(described_class, "# Title\n\n### Detail\n")
    expect(result.map(&:line)).to eq([3])
  end

  it 'allows a deep initial heading, increments and decreases' do
    expect(offenses(described_class, "### Start\n\n#### Detail\n\n# Restart\n\n## Child\n")).to be_empty
  end

  it 'includes Setext and container headings' do
    expect(offenses(described_class, "Title\n=====\n\n> ### Detail\n").size).to eq(1)
  end

  it 'ignores front matter, code and escaped markers' do
    source = "---\ntitle: '### ignored'\n---\n# Title\n\n```md\n###### Code\n```\n\n    ##### Code\n\n\\##### Literal\n\n## Child\n"
    expect(offenses(described_class, source)).to be_empty
  end

  it 'does not autocorrect structure' do
    source = "# Title\n\n### Detail\n"
    expect(corrected(described_class, source)).to eq(source)
  end
end
