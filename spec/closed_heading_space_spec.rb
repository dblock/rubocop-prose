# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Prose::ClosedHeadingSpace do
  it 'reports attached closing hashes' do
    expect(offenses(described_class, "## Résumé##\n").size).to eq(1)
  end

  it 'accepts closed and ordinary headings' do
    expect(offenses(described_class, "# Title #\n\n## Detail\n\n###\n")).to be_empty
  end

  it 'ignores an escaped final hash run' do
    expect(offenses(described_class, "# C\\#\n\n## Text\\##\n")).to be_empty
  end

  it 'recognizes an even backslash run before the suffix' do
    expect(offenses(described_class, "# Text\\\\#\n").size).to eq(1)
  end

  it 'ignores code, escaped opening hashes and malformed opening spacing' do
    expect(offenses(described_class, "```\n# Code#\n```\n\n\\# Text#\n\n##Text##\n")).to be_empty
  end

  it 'does not strip literal suffixes through autocorrection' do
    expect(corrected(described_class, "# C#\n")).to eq("# C#\n")
  end
end
