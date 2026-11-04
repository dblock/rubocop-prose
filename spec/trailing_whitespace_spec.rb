# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Markdown::TrailingWhitespace do
  it 'removes unexpected spaces but retains and normalizes paragraph hard breaks' do
    source = "First \nsecond  \nthird   \nfourth.\n"
    expect(corrected(described_class, source, settings: { 'Markdown/HardBreakStyle' => { 'Enabled' => false } }))
      .to eq("First\nsecond  \nthird  \nfourth.\n")
  end

  it 'supports a configured hard-break width without dropping rendered breaks' do
    expect(corrected(described_class, "First  \nsecond.\n", { 'HardBreakSpaces' => 4 },
                     settings: { 'Markdown/HardBreakStyle' => { 'Enabled' => false } }))
      .to eq("First    \nsecond.\n")
  end

  it 'excludes metadata and code and does not autocorrect opted-in code' do
    source = "---\ntitle: metadata \n---\n\n```ruby\nputs 1 \n```\n"
    expect(offenses(described_class, source)).to be_empty
    expect(offenses(described_class, source, 'CodeBlocks' => true).map(&:line)).to eq([6])
    expect(corrected(described_class, source, 'CodeBlocks' => true)).to eq(source)
  end

  it 'leaves style-policy hard breaks to Markdown/HardBreakStyle' do
    source = "First line.   \nSecond line.\n"
    style = RuboCop::Cop::Markdown::HardBreakStyle
    expect(corrected([described_class, style], source)).to eq("First line.\\\nSecond line.\n")
  end
end
