# frozen_string_literal: true

require 'digest'
require 'json'
require 'rubocop-prose'

class ProseBenchmark
  def initialize
    @iterations = Integer(ENV.fetch('ITERATIONS', '5'), 10)
    @sizes = ENV.fetch('SECTIONS', '10,50').split(',', -1).map { |value| Integer(value, 10) }
    unless @iterations.positive? && @sizes.all?(&:positive?)
      raise ArgumentError, 'ITERATIONS and SECTIONS must be positive integers.'
    end

    path = File.expand_path('../.rubocop.yml', __dir__)
    @configurations = {
      default: RuboCop::ConfigLoader.merge_with_default(
        RuboCop::Config.new(RuboCop::Prose.default_configuration), path
      ),
      project: RuboCop::ConfigLoader.merge_with_default(RuboCop::ConfigLoader.load_file(path), path)
    }
  end

  def run
    puts RUBY_DESCRIPTION
    puts "RuboCop #{RuboCop::Version::STRING}; #{@iterations} iterations; median time and allocations per operation"
    puts 'Operation                  Sections      Bytes      Seconds      Objects      Fingerprint'
    @sizes.each do |size|
      { markdown: markdown(size), text: text(size) }.each do |format, source|
        measure("document/#{format}", size, source) { document(source, format) }
        measure('analysis/markdown', size, source) { markdown_analysis(source) } if format == :markdown
        @configurations.each do |profile, configuration|
          cops = RuboCop::Cop::Registry.global.select do |cop|
            %i[Prose Markdown Text].include?(cop.department) && configuration[cop.cop_name]['Enabled']
          end
          [false, true].each do |autocorrect|
            name = autocorrect ? 'correct' : 'lint'
            measure("#{name}/#{profile}/#{format}", size, source) do
              investigate(source, format, configuration, cops, autocorrect: autocorrect)
            end
          end
        end
      end
    end
  end

  private

  def measure(name, size, source)
    expected = fingerprint(yield)
    times = []
    allocations = []
    @iterations.times do
      GC.start
      before = GC.stat(:total_allocated_objects)
      started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      result = yield
      times << (Process.clock_gettime(Process::CLOCK_MONOTONIC) - started)
      allocations << (GC.stat(:total_allocated_objects) - before)
      raise "Unstable benchmark output: #{name}, #{size} sections." unless fingerprint(result) == expected
    end
    puts format('%<name>-26s %<size>8d %<bytes>10d %<seconds>12.6f %<objects>12.0f %<fingerprint>16s',
                name: name, size: size, bytes: source.bytesize, seconds: median(times),
                objects: median(allocations), fingerprint: expected[0, 16])
  end

  def median(values)
    sorted = values.sort
    (sorted[(sorted.length - 1) / 2] + sorted[sorted.length / 2]) / 2.0
  end

  def fingerprint(result)
    Digest::SHA256.hexdigest(JSON.generate(result))
  end

  def document(source, format)
    buffer = Parser::Source::Buffer.new(path(format), source: source)
    document = RuboCop::Prose::Document.build(path(format), buffer)
    return document.paragraphs.map(&:to_a) if format == :text

    paragraphs = document.paragraphs.map do |paragraph|
      [document.line_numbers(paragraph).to_a,
       document.atomic_ranges(paragraph).map { |range| [range.begin_pos, range.end_pos] }]
    end
    [document.headings, paragraphs, document.warnings]
  end

  def investigate(source, format, configuration, cops, autocorrect:)
    processed = RuboCop::ProcessedSource.new(source, 3.2, path(format), prose_configuration: configuration)
    processed.config = configuration if processed.respond_to?(:config=)
    processed.registry = RuboCop::Cop::Registry.new(cops) if processed.respond_to?(:registry=)
    options = { raise_error: true, autocorrect: autocorrect, stdin: source }
    team = RuboCop::Cop::Team.mobilize(cops, configuration, options)
    report = team.investigate(processed)
    offenses = report.offenses.map do |offense|
      [offense.cop_name, offense.location.begin_pos, offense.location.end_pos, offense.message, offense.severity.name]
    end.sort
    [offenses, options.fetch(:stdin)]
  end

  def markdown_analysis(source)
    buffer = Parser::Source::Buffer.new(path(:markdown), source: source)
    document = RuboCop::Prose::Document.build(path(:markdown), buffer)
    links = document.link_rules
    [links.links.map(&:to_a), links.definitions.map(&:to_a),
     document.tables.map { |table| table.rows.map { |row| [row.number, row.cells.map(&:to_a)] } },
     %i[em strong].map do |type|
       document.emphasis_ranges(type).map do |opening, closing, marker|
         [opening.begin_pos, opening.end_pos, closing.begin_pos, closing.end_pos, marker]
       end
     end]
  end

  def path(format)
    format == :markdown ? 'benchmark.md' : 'benchmark.txt'
  end

  def markdown(size)
    sections = Array.new(size) do |index|
      <<~MARKDOWN
        ## Section #{index}

        Unicode \u{1F600} prose with *emphasis*, **strong text**, [a guide][guide-#{index}], and `inline code`
        continues with a [link](https://example.test/guide).

        > Quoted prose with an [example](https://example.test/quote)
        > continues on another source line.

        - A list item with _emphasis_
          continues with **strong text**.

        9. a short item
        10. Another item with github, markdown, and ruby.

        ### Repeated heading

        `fixed` spacing preserves YAML and RuboCop names.

        | Feature | Value |
        | --- | --- |
        | Name | `code` |

        ```ruby
        puts 'hello'
        ```

        [guide-#{index}]: https://example.test/guide

      MARKDOWN
    end.join
    "---\ntitle: Benchmark\n---\n\n# Benchmark\n\n#{sections}"
  end

  def text(size)
    Array.new(size) do |index|
      "Section #{index}: Unicode \u{1F600} prose with literal [brackets], `code`, and <tags>.\n" \
        "A second source line continues the paragraph.\n\n" \
        "lowercase prose mentions github, markdown, and ruby.\t\n\n"
    end.join
  end
end

ProseBenchmark.new.run
