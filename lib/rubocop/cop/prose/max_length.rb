# frozen_string_literal: true

module RuboCop
  module Cop
    module Prose
      class MaxLength < Base
        extend AutoCorrector

        MSG = 'Prose line is too long. [%<length>d/%<max>d]'
        UNWRAP_MSG = 'Keep paragraph text on a single source line.'
        BLOCK_START = /\A(?:[>#]|[-+*](?:\s|\z)|\d+[.)](?:\s|\z)|`{3}|~{3}|[=-]+[\t ]*\z)/

        def validate_config
          return if cop_config['Max'] == false

          %w[Max HeadingMax CodeBlockMax].each do |name|
            value = cop_config[name]
            next if name != 'Max' && value.nil?
            next if value.is_a?(Integer) && value.positive?

            raise ValidationError, "Prose/MaxLength: #{name} must be a positive integer (or Max: false)."
          end
        end

        private

        def investigate_document
          super
          return if cop_config['Max'] == false

          table_lines = document.nodes(:table).flat_map do |table|
            first = table.options.fetch(:location)
            rows = table.children.sum { |section| section.children.length }
            (first..(first + rows)).to_a
          end.to_set
          heading_lines = document.headings.to_set(&:last)
          document.lines.each_with_index do |text, index|
            number = index + 1
            next if document.front_matter_line?(number)

            limit = structural_limit(number, heading_lines, table_lines)
            next unless limit && text.length > limit

            prose_offense(document.range(number, limit),
                          message: format(MSG, length: text.length, max: limit))
          end
        end

        def structural_limit(number, headings, tables)
          if headings.include?(number) && cop_config['Headings']
            cop_config['HeadingMax'] || cop_config['Max']
          elsif document.code_line?(number) && cop_config['CodeBlocks']
            cop_config['CodeBlockMax'] || cop_config['Max']
          elsif tables.include?(number) && cop_config['Tables']
            cop_config['Max']
          end
        end

        def investigate_paragraph(paragraph)
          return unwrap_paragraph(paragraph) if cop_config['Max'] == false

          document.line_numbers(paragraph).each { |number| inspect_line(paragraph, number) }
        end

        def unwrap_paragraph(paragraph)
          document.soft_breaks(paragraph).each do |number|
            previous = document.line(number)
            following = document.line(number + 1)
            column = document.content_start(paragraph, number + 1)
            next if previous.match?(/<br\b[^>]*>\s*\z/i) || following[column..].match?(/\A<br\b[^>]*>/i)

            join = document.range(number, previous.rstrip.length, number + 1, column)
            offense = document.range(number + 1, column)
            prose_offense(offense, message: UNWRAP_MSG) do |corrector|
              corrector.replace(processed_range(join), ' ')
            end
          end
        end

        def inspect_line(paragraph, number)
          text = document.line(number)
          max = cop_config['Max']
          return if text.length <= max

          first = document.content_start(paragraph, number)
          return if cop_config['IgnoreURLs'] && text[first..].strip.match?(%r{\A<?https?://\S+>?\z})

          range = document.range(number, [first, max].max, number, text.length)
          prefix = document.continuation_prefix(paragraph)
          breaks = wrap_points(text, number, first, prefix, document.atomic_ranges(paragraph))
          prose_offense(range, message: format(MSG, length: text.length, max: max)) do |corrector|
            breaks.each { |space| corrector.replace(processed_range(space), "\n#{prefix}") }
          end
        end

        def wrap_points(text, number, first, prefix, atomic)
          spaces = breakable_spaces(text, number, first, atomic)
          breaks = []
          start = 0
          width = cop_config['Max']
          while text.length - start > width
            candidates = spaces.select { |space| space.column > start }
            chosen = candidates.reverse.find { |space| space.column - start <= width }
            chosen ||= candidates.first
            break unless chosen

            breaks << chosen
            start = chosen.last_column
            width = cop_config['Max'] - prefix.length
          end
          breaks
        end

        def breakable_spaces(text, number, first, atomic)
          spaces = []
          text.to_enum(:scan, /[ \t]+/).each do
            match = Regexp.last_match
            next if match.begin(0) <= first || match.end(0) == text.length
            next if text[match.end(0)..].match?(BLOCK_START)
            next if text[0...match.begin(0)][/\\+\z/].to_s.length.odd?

            range = document.range(number, match.begin(0), number, match.end(0))
            spaces << range unless atomic.any? { |protected| protected.overlaps?(range) }
          end
          spaces
        end
      end
    end
  end
end
