# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Prose::SingleTopLevelHeading do
  it 'reports every extra top-level heading' do
    expect(offenses(described_class, "# One\n\n# Two\n\n# Three\n").map(&:line)).to eq([3, 5])
  end

  it 'allows one or no top-level heading' do
    expect(offenses(described_class, "# One\n\n## Child\n")).to be_empty
    expect(offenses(described_class, "## Only child\n")).to be_empty
  end

  it 'supports a configured level' do
    expect(offenses(described_class, "## One\n\n## Two\n", { 'Level' => 2 }).size).to eq(1)
  end

  it 'includes Setext headings' do
    expect(offenses(described_class, "# One\n\nTwo\n===\n").size).to eq(1)
  end

  it 'does not count front-matter titles, code or escaped headings' do
    source = "---\ntitle: One\n---\n# One\n\n```\n# Code\n```\n\n    # Code\n\n\\# Literal\n"
    expect(offenses(described_class, source)).to be_empty
  end

  it 'does not demote headings' do
    source = "# One\n\n# Two\n"
    expect(corrected(described_class, source)).to eq(source)
  end
end
