# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Markdown::ShellPrompts do
  it 'removes prompts from commands without output and is idempotent' do
    source = "```sh\n$ echo one\n\n$ echo two\n```\n"
    expect(offenses(described_class, source).size).to eq(2)
    result = corrected(described_class, source)
    expect(result).to eq("```sh\necho one\n\necho two\n```\n")
    expect(offenses(described_class, result)).to be_empty
  end

  it 'preserves quote and list container prefixes' do
    expect(corrected(described_class, "> - ```bash\n>   $ echo hi\n>   ```\n")).to eq("> - ```bash\n>   echo hi\n>   ```\n")
  end

  it 'removes mixed default prompts while preserving comments and blank lines' do
    source = "```sh\n# Keep this shell comment.\n$ echo hello\n\n% echo hello\n  # Keep this too.\n```\n"
    result = corrected(described_class, source)

    expect(offenses(described_class, source).map { |offense| offense.location.source }).to eq(['$ ', '% '])
    expect(result).to eq("```sh\n# Keep this shell comment.\necho hello\n\necho hello\n  # Keep this too.\n```\n")
    expect(corrected(described_class, result)).to eq(result)
    expect(offenses(described_class, result)).to be_empty
  end

  it 'preserves alternative prompt locations and nested containers after Unicode' do
    source = "Pr\u00e9face\n\n> - ```zsh\n>   % echo h\u00e9llo\n>   # Keep this comment.\n>   ```\n"
    offense = offenses(described_class, source).first

    expect([offense.location.line, offense.location.column, offense.location.source]).to eq([4, 4, '% '])
    result = corrected(described_class, source)
    expect(result).to eq("Pr\u00e9face\n\n> - ```zsh\n>   echo h\u00e9llo\n>   # Keep this comment.\n>   ```\n")
    expect(corrected(described_class, result)).to eq(result)
  end

  it 'ignores output, other languages, unlabeled fences, and indented code' do
    source = "```console\n$ echo hi\nhi\n```\n\n```ruby\n$ variable\n```\n\n```\n$ unknown\n```\n\n    $ command\n"
    expect(offenses(described_class, source)).to be_empty
  end

  it 'supports additional shell languages' do
    expect(offenses(described_class, "~~~fish\n% echo hello\n~~~\n", 'ShellLanguages' => ['fish']).size).to eq(1)
  end

  it 'replaces default prompts with an explicit positive set' do
    options = { 'Prompts' => ['❯', 'user$'] }
    source = "```sh\n❯ echo hello\nuser$ echo hello\n```\n"
    result = corrected(described_class, source, options)

    expect(offenses(described_class, source, options).map { |offense| offense.location.source }).to eq(['❯ ', 'user$ '])
    expect(result).to eq("```sh\necho hello\necho hello\n```\n")
    expect(offenses(described_class, result, options)).to be_empty
    expect(offenses(described_class, "```sh\n$ echo hello\n% echo hello\n```\n", options)).to be_empty
  end

  it 'accepts a percent-only configuration without requiring dollar prompts' do
    options = { 'Prompts' => ['%'] }
    source = "```sh\n% echo hello\n# Keep this shell comment.\n```\n"

    expect(corrected(described_class, source, options)).to eq("```sh\necho hello\n# Keep this shell comment.\n```\n")
  end

  it 'does not interpret comments as prompts by default' do
    source = "```sh\n# echo hello\n## Keep this shell comment.\n```\n"

    expect(offenses(described_class, source)).to be_empty
    expect(corrected(described_class, source)).to eq(source)
  end

  it 'keeps explicitly configured comment-like prompts report-only for the whole block' do
    ['#', '##'].each do |prompt|
      source = "```sh\n% echo hello\n#{prompt} echo hello\n#{prompt} Keep this shell comment.\n```\n"
      options = { 'Prompts' => ['%', prompt] }

      expect(offenses(described_class, source, options).size).to eq(3)
      expect(corrected(described_class, source, options)).to eq(source)
      expect(corrected(described_class, corrected(described_class, source, options), options)).to eq(source)
    end
  end

  it 'leaves output and unprompted continuations untouched with alternative prompts' do
    sources = [
      "```sh\n% echo hello\nhello\n```\n",
      "```sh\n% echo hello \\\n  world\n```\n",
      "```sh\n% echo hello\n> continued\n```\n",
      "```sh\n% echo hello\n$echo hello\n```\n"
    ]

    sources.each do |source|
      expect(offenses(described_class, source)).to be_empty
      expect(corrected(described_class, source)).to eq(source)
    end
  end

  it 'requires a literal prompt followed by a space in a configured language' do
    source = "```sh\n%echo hello\n```\n\n```SH\n% echo hello\n```\n\n```sh\n%\techo hello\n```\n"

    expect(offenses(described_class, source)).to be_empty
  end

  it 'rejects invalid prompt and language settings' do
    {
      'Prompts' => [nil, '$', [], [''], ['a b'], [1], ["%\n"]],
      'ShellLanguages' => [nil, 'sh', [''], ['shell language'], [false]]
    }.each do |name, values|
      values.each do |value|
        expect do
          offenses(described_class, "```sh\n% echo hello\n```\n", name => value)
        end.to raise_error(RuboCop::ValidationError, /#{name} must be an array of nonempty strings without whitespace/)
      end
    end
  end

  it 'rejects missing settings after configuration merging removes nil values' do
    %w[Prompts ShellLanguages].each do |name|
      settings = RuboCop::Prose.default_configuration.fetch(described_class.cop_name).dup
      settings.delete(name)
      cop = described_class.new(RuboCop::Config.new(described_class.cop_name => settings))

      expect { cop.validate_config }.to raise_error(
        RuboCop::ValidationError, /#{name} must be an array of nonempty strings without whitespace/
      )
    end
  end

  it 'reports without exposing a fence-closing command during correction' do
    source = "```sh\n$ ```\n$ echo hi\n```\n"
    expect(offenses(described_class, source).size).to eq(2)
    expect(corrected(described_class, source)).to eq(source)
  end

  it 'withholds mixed-prompt corrections that could expose nested backtick or tilde fences' do
    %w[``` ~~~].each do |fence|
      source = "> - #{fence}sh\n>   %   #{fence}\n>   $ echo hello\n>   #{fence}\n"

      expect(offenses(described_class, source).size).to eq(2)
      expect(corrected(described_class, source)).to eq(source)
    end
  end
end
