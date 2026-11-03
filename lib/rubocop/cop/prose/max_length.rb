# frozen_string_literal: true

module RuboCop
  module Cop
    module Prose
      class MaxLength < Base
        extend AutoCorrector

        MSG = 'Prose line is too long. [%<length>d/%<max>d]'
        BLOCK_START = /\A(?:[>#]|[-+*](?:\s|\z)|\d+[.)](?:\s|\z)|`{3}|~{3}|[=-]+[\t ]*\z)/

        def validate_config
          return if cop_config['Max'].is_a?(Integer) && cop_config['Max'].positive?

          raise ValidationError, 'Prose/MaxLength: Max must be a positive integer.'
        end

        private

        def investigate_paragraph(paragraph)
          document.line_numbers(paragraph).each { |number| inspect_line(paragraph, number) }
        end

        def inspect_line(paragraph, number)
          text = document.line(number)
          max = cop_config['Max']
          return if text.length <= max

          first = document.content_start(paragraph, number)
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
