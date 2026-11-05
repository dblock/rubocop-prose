# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Prose::HardTabs do
  it 'directs the old Markdown name to Prose/HardTabs' do
    config = RuboCop::Config.new({ 'Markdown/HardTabs' => { 'Enabled' => true } }, '.rubocop.yml')
    expect { RuboCop::ConfigObsoletion.new(config).reject_obsolete! }
      .to raise_error(RuboCop::ValidationError, %r{Markdown/HardTabs.*Prose/HardTabs}m)
  end

  it 'reports exact Unicode-aware tab locations without guessing a correction' do
    source = "Hello \u{1f600}\tworld.\n"
    result = offenses(described_class, source)
    expect(result.map(&:column)).to eq([7])
    expect(corrected(described_class, source)).to eq(source)
  end

  it 'ignores code by default and supports language exceptions when code checking is enabled' do
    source = "```make\n\ttarget:\n```\n"
    expect(offenses(described_class, source)).to be_empty
    expect(offenses(described_class, source, 'CodeBlocks' => true).map(&:line)).to eq([2])
    expect(offenses(described_class, source, 'CodeBlocks' => true, 'AllowedCodeLanguages' => ['make'])).to be_empty
  end

  it 'does not report front matter or tab-free prose' do
    expect(offenses(described_class, "---\ntitle:\tvalue\n---\n\nText.\n")).to be_empty
  end

  it 'reports tabs literally throughout plain text and never corrects them' do
    source = "```make\tlabel\n\tcommand\n---\nmetadata:\tvalue\n"
    settings = { 'CodeBlocks' => false, 'AllowedCodeLanguages' => ['make'] }
    found = offenses(described_class, source, settings, path: 'example.txt')
    expect(found.map { |offense| [offense.line, offense.column] }).to eq([[1, 7], [2, 0], [4, 9]])
    expect(corrected(described_class, source, settings, path: 'example.txt')).to eq(source)
  end
end
