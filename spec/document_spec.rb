# frozen_string_literal: true

RSpec.describe RuboCop::Prose::MarkdownDocument do
  def document(source)
    described_class.new(Parser::Source::Buffer.new('test.md', source: source))
  end

  it 'retains original Unicode coordinates and nested paragraph prefixes' do
    source = "# Heading\n\n> Unicode \u{1f600}\n> continues.\n"
    doc = document(source)
    paragraph = doc.paragraphs.first
    expect(doc.source).to eq(source)
    expect(doc.headings).to eq([[1, 'Heading', 1]])
    expect(doc.content_start(paragraph, 3)).to eq(2)
    expect(doc.range(3, 2).source).to eq("Unicode \u{1f600}")
    expect(doc.soft_breaks(paragraph)).to eq([3])
  end

  it 'excludes closed front matter and fenced and indented code from prose lines' do
    source = "---\ntitle: metadata\n---\n\n~~~ruby\nputs 1\n~~~\n\n    puts 2\n"
    doc = document(source)
    expect(doc.prose_lines.to_a).to eq([['', 4], ['', 8]])
  end

  it 'does not parse Markdown as Ruby or change ordinary Ruby buffers' do
    markdown = RuboCop::ProcessedSource.new("# Text\n\nNot Ruby.\n", 3.2, 'test.md')
    ruby = RuboCop::ProcessedSource.new('puts 1', 3.2, 'test.rb')
    expect(markdown.valid_syntax?).to be(false)
    expect(markdown.buffer.source).to include('Not Ruby.')
    expect(ruby.valid_syntax?).to be(true)
    expect(ruby.ast.type).to eq(:send)
  end

  it 'indexes the AST once across different structural queries' do
    doc = document("# Heading\n\n> Paragraph.\n\n~~~ruby\nputs 1\n~~~\n")
    allow(doc.root).to receive(:children).and_call_original

    expect(doc.nodes(:header).map { |node| node.options[:location] }).to eq([1])
    expect(doc.paragraphs.map { |node| node.options[:location] }).to eq([3])
    expect(doc.nodes(:codeblock).map { |node| node.options[:location] }).to eq([5])
    expect(doc.nodes(:missing)).to be_empty
    expect(doc.root).to have_received(:children).once
  end

  it 'collects multiline atoms once while masking different source lines' do
    doc = document("Prefix `two\nlines` suffix.\n\nVisible.\n")
    allow(doc).to receive(:atomic_ranges).and_call_original

    masks = [1, 2, 4].map do |number|
      RuboCop::Prose::InlineRules.mask(doc.line(number), document: doc, number: number)
    end
    expect(masks).to eq(["Prefix #{' ' * 4}", "#{' ' * 6} suffix.", 'Visible.'])
    expect(doc).to have_received(:atomic_ranges).twice
  end

  it 'shares link scanning between cops and retains the first normalized definition' do
    source = "Unicode \u{1F600} [ here ][Doc].\n\n[DOC]: /first\n[doc]: <>\n"
    cops = [
      RuboCop::Cop::Markdown::ReferenceDefinitions, RuboCop::Cop::Markdown::DescriptiveLinkText,
      RuboCop::Cop::Markdown::EmptyLink,
      RuboCop::Cop::Markdown::UndefinedReference
    ]
    allow(RuboCop::Prose::LinkRules).to receive(:new).and_call_original

    offenses, result = investigate(cops, source)
    expect(offenses.map(&:cop_name)).to contain_exactly(
      'Markdown/ReferenceDefinitions', 'Markdown/DescriptiveLinkText'
    )
    expect(result).to eq(source)
    expect(RuboCop::Prose::LinkRules).to have_received(:new).once
  end

  it 'preserves both emphasis types and Unicode corrections across style and spacing cops' do
    source = "😀 _first_ and __bold__.\n\n> café *word* and **text**.\n"
    expected = "😀 _first_ and __bold__.\n\n> café _word_ and __text__.\n"
    cops = [
      RuboCop::Cop::Markdown::OutsideSpacing,
      RuboCop::Cop::Markdown::EmphasisStyle, RuboCop::Cop::Markdown::StrongStyle
    ]

    result, rewritten = investigate(cops, source, { 'Style' => 'underscore' })
    expect(result.map { |offense| [offense.cop_name, offense.location.source, offense.location.column] }).to eq(
      [['Markdown/EmphasisStyle', '*', 7], ['Markdown/StrongStyle', '**', 18]]
    )
    expect(rewritten).to eq("😀 _first_ and __bold__.\n\n> café _word_ and **text**.\n")
    rewritten = corrected(cops, rewritten, { 'Style' => 'underscore' })
    expect(rewritten).to eq(expected)
    expect(offenses(cops, rewritten, { 'Style' => 'underscore' })).to be_empty
    result = offenses(cops, rewritten, { 'Style' => 'asterisk' })
    expect(result.map(&:cop_name)).to contain_exactly(
      'Markdown/EmphasisStyle', 'Markdown/StrongStyle', 'Markdown/EmphasisStyle', 'Markdown/StrongStyle'
    )
  end

  it 'keeps emphasis ranges isolated between effective front-matter configurations' do
    source = "---\ntitle: *hidden* and **secret**\n---\n\n😀 *visible* and **bold**.\n"
    processed = RuboCop::ProcessedSource.new(source, 3.2, 'test.md')
    ignored = processed.prose_document(configuration: { 'Markdown' => { 'IgnoreFrontMatter' => true } })
    included = processed.prose_document(configuration: { 'Markdown' => { 'IgnoreFrontMatter' => false } })
    ranges = lambda do |doc, type|
      doc.emphasis_ranges(type).map { |opening, closing, _| [opening.line, opening.column, closing.column] }
    end

    expect(ranges.call(ignored, :em)).to eq([[5, 2, 10]])
    expect(ranges.call(included, :strong)).to eq([[2, 20, 28], [5, 16, 22]])
    expect(ranges.call(ignored, :strong)).to eq([[5, 16, 22]])
    expect(ranges.call(included, :em)).to eq([[2, 7, 14], [5, 2, 10]])
  end
end
