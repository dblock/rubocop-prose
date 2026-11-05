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

  it 'trims single spaces from empty quote lines by default and when explicitly disabled' do
    source = "> First.\n> \n> > Nested.\n> > \n>> \n> > End.\n"
    expected = "> First.\n>\n> > Nested.\n> >\n>>\n> > End.\n"

    expect(corrected(described_class, source)).to eq(expected)
    expect(corrected(described_class, source, 'AllowEmptyBlockquoteSpace' => false)).to eq(expected)
  end

  it 'allows exactly one space on empty quote lines at any nesting depth' do
    source = "> First.\n> \n>\n> > Nested.\n> > \n>> \n> > End.\n> > > \n\n> \n"

    expect(offenses(described_class, source, 'AllowEmptyBlockquoteSpace' => true)).to be_empty
    expect(corrected(described_class, source, 'AllowEmptyBlockquoteSpace' => true)).to eq(source)
  end

  it 'rejects wider and mixed trailing whitespace even on empty nested quote lines' do
    source = "> First.\n>  \n>\t\n> \t \n> > Nested.\n> >   \n>>\t \n> > End.\n"
    options = { 'AllowEmptyBlockquoteSpace' => true }

    expect(offenses(described_class, source, options).map(&:line)).to eq([2, 3, 4, 6, 7])
    expect(corrected(described_class, source, options))
      .to eq("> First.\n>\n>\n>\n> > Nested.\n> >\n>>\n> > End.\n")
  end

  it 'does not excuse trailing spaces on nonempty quotes, escaped markers, or root blank lines' do
    source = "> Words. \n> Next.\n\n\\> \n \n"
    options = { 'AllowEmptyBlockquoteSpace' => true }

    expect(offenses(described_class, source, options).map(&:line)).to eq([1, 4, 5])
    expect(corrected(described_class, source, options)).to eq("> Words.\n> Next.\n\n\\>\n\n")
  end

  it 'preserves paragraph hard-break handling with the empty quote exception enabled' do
    source = "> First.   \n> Next.\n> \n> Last.\n"
    options = { 'AllowEmptyBlockquoteSpace' => true, 'HardBreakSpaces' => 4 }
    settings = { 'Markdown/HardBreakStyle' => { 'Enabled' => false } }

    expect(corrected(described_class, source, options, settings: settings))
      .to eq("> First.    \n> Next.\n> \n> Last.\n")
    expect(corrected([described_class, RuboCop::Cop::Markdown::HardBreakStyle], source,
                     'AllowEmptyBlockquoteSpace' => true)).to eq("> First.\\\n> Next.\n> \n> Last.\n")
  end

  it 'excludes quoted and unquoted code without exempting report-only code whitespace' do
    source = "```\n> \n```\n\n    > \n\n> ```\n> > \n> ```\n"
    options = { 'AllowEmptyBlockquoteSpace' => true }

    expect(offenses(described_class, source, options)).to be_empty
    expect(offenses(described_class, source, options.merge('CodeBlocks' => true)).map(&:line)).to eq([2, 5, 8])
    expect(corrected(described_class, source, options.merge('CodeBlocks' => true))).to eq(source)
  end

  it 'handles CRLF input while trimming only disallowed quote whitespace' do
    source = "> First.\r\n> \r\n> > Nested.\r\n> >  \r\n> > End.\r\n"

    expect(corrected(described_class, source, 'AllowEmptyBlockquoteSpace' => true))
      .to eq("> First.\n> \n> > Nested.\n> >\n> > End.\n")
  end
end
