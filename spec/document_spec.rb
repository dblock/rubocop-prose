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
    expect(doc.root).to receive(:children).once.and_call_original

    expect(doc.nodes(:header).map { |node| node.options[:location] }).to eq([1])
    expect(doc.paragraphs.map { |node| node.options[:location] }).to eq([3])
    expect(doc.nodes(:codeblock).map { |node| node.options[:location] }).to eq([5])
    expect(doc.nodes(:missing)).to be_empty
  end

  it 'collects multiline atoms once while masking different source lines' do
    doc = document("Prefix `two\nlines` suffix.\n\nVisible.\n")
    expect(doc).to receive(:atomic_ranges).twice.and_call_original

    masks = [1, 2, 4].map do |number|
      RuboCop::Prose::InlineRules.mask(doc.line(number), document: doc, number: number)
    end
    expect(masks).to eq(["Prefix #{' ' * 4}", "#{' ' * 6} suffix.", 'Visible.'])
  end

  it 'shares link scanning between cops and retains the first normalized definition' do
    source = "Unicode \u{1F600} [ here ][Doc].\n\n[DOC]: /first\n[doc]: <>\n"
    cops = [
      RuboCop::Cop::Markdown::ReferenceDefinitions, RuboCop::Cop::Markdown::DescriptiveLinkText,
      RuboCop::Cop::Markdown::EmptyLink,
      RuboCop::Cop::Markdown::UndefinedReference
    ]
    expect(RuboCop::Prose::LinkRules).to receive(:new).once.and_call_original

    offenses, result = investigate(cops, source)
    expect(offenses.map(&:cop_name)).to contain_exactly(
      'Markdown/ReferenceDefinitions', 'Markdown/DescriptiveLinkText'
    )
    expect(result).to eq(source)
  end
end
