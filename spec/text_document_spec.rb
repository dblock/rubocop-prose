# frozen_string_literal: true

RSpec.describe RuboCop::Prose::TextDocument do
  def document(source)
    described_class.new(Parser::Source::Buffer.new('example.txt', source: source))
  end

  it 'forms blank-line-delimited paragraphs without interpreting Markdown markers' do
    doc = document("---\n# Heading\n```\n<br>\n\nNext paragraph.\n")
    expect(doc.paragraphs.map { |paragraph| doc.line_numbers(paragraph).to_a }).to eq([[1, 2, 3, 4], [6]])
    expect(doc.atomic_ranges(doc.paragraphs.first)).to be_empty
    expect(doc.soft_breaks(doc.paragraphs.first)).to eq([1, 2, 3])
  end

  it 'retains Unicode ranges and refuses to reflow ambiguous indentation' do
    doc = document("Hello \u{1f600}\n  indented continuation\n")
    expect(doc.range(1, 6).source).to eq("\u{1f600}")
    expect(doc.reflowable?(doc.paragraphs.first)).to be(false)
  end

  it 'dispatches uppercase text extensions without parsing Ruby or creating directives' do
    source = "# rubocop:disable all\nNot Ruby.\n"
    processed = RuboCop::ProcessedSource.new(source, 3.2, 'example.TXT')
    expect(processed.prose_document).to be_a(described_class)
    expect(processed.buffer.source).to eq(source)
    expect(processed.ast).to be_nil
    expect(processed.valid_syntax?).to be(false)
    expect(processed.comments).to be_empty
  end

  it 'never consults an optional Markdown mapping for plain text' do
    processed = RuboCop::ProcessedSource.new("Text.\n", 3.2, 'example.txt')
    processed.define_singleton_method(:markdown_document) { raise 'Must not use Markdown mapping for text' }
    expect(processed.prose_document).to be_a(described_class)
    expect(processed.prose_markdown_document).to be_nil
  end
end
