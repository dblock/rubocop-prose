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

  it 'ignores output, other languages, unlabeled fences, and indented code' do
    source = "```console\n$ echo hi\nhi\n```\n\n```ruby\n$ variable\n```\n\n```\n$ unknown\n```\n\n    $ command\n"
    expect(offenses(described_class, source)).to be_empty
  end

  it 'supports additional shell languages' do
    expect(offenses(described_class, "~~~fish\n$ pwd\n~~~\n", 'ShellLanguages' => ['fish']).size).to eq(1)
  end

  it 'reports without exposing a fence-closing command during correction' do
    source = "```sh\n$ ```\n$ echo hi\n```\n"
    expect(offenses(described_class, source).size).to eq(2)
    expect(corrected(described_class, source)).to eq(source)
  end
end
