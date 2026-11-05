# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Markdown::StructuralLineLength do
  it 'reports heading source without rewriting its structure' do
    source = "# A very long heading\n"
    expect(offenses(described_class, source, 'Headings' => 10).map(&:line)).to eq([1])
    expect(corrected(described_class, source, 'Headings' => 10)).to eq(source)
    expect(offenses(described_class, source, 'Headings' => false)).to be_empty
  end

  it 'defaults to 80-character headings and leaves code blocks and tables unchecked' do
    source = "# #{'h' * 80}\n\n```text\n#{'c' * 90}\n```\n\n| #{'t' * 80} |\n| --- |\n"
    expect(offenses(described_class, source).map(&:line)).to eq([1])
  end

  it 'checks code with its own limit while leaving code untouched' do
    source = "```ruby\nputs 'long code'\n```\n"
    expect(offenses(described_class, source, 'CodeBlocks' => false)).to be_empty
    options = { 'CodeBlocks' => 8 }
    expect(offenses(described_class, source, options).map(&:line)).to eq([2])
    expect(corrected(described_class, source, options)).to eq(source)
  end

  it 'optionally reports table source including delimiters without reflowing cells' do
    source = "| name | value |\n| --- | --- |\n| a | b |\n"
    expect(offenses(described_class, source, 'Tables' => false)).to be_empty
    expect(offenses(described_class, source, 'Tables' => 10).map(&:line)).to eq([1, 2])
    expect(corrected(described_class, source, 'Tables' => 10)).to eq(source)
  end

  it 'rejects values other than positive integers and false' do
    %w[Headings CodeBlocks Tables].each do |name|
      [true, nil, 0, -1, 1.5, '10'].each do |value|
        expect do
          offenses(described_class, "# Heading\n", name => value)
        end.to raise_error(RuboCop::ValidationError, /#{name} must be a positive integer or false/)
      end
    end
  end

  it 'uses character widths for Unicode and does not check text files' do
    source = "# éééééééé\n"
    expect(offenses(described_class, source, 'Headings' => 8).map { |offense| offense.location.column }).to eq([8])
    expect(offenses(described_class, "# A long text line\n", { 'Headings' => 5 }, path: 'example.txt')).to be_empty
  end

  it 'rejects removed parameters with standard migration diagnostics' do
    %w[Max HeadingMax CodeBlockMax].each do |name|
      config = RuboCop::Config.new(
        { 'Markdown/StructuralLineLength' => { name => 80 } }, '.rubocop.yml'
      )
      expect { RuboCop::ConfigObsoletion.new(config).reject_obsolete! }
        .to raise_error(RuboCop::ValidationError, /obsolete parameter `#{name}`.*Headings: 120/m)
    end
  end
end
