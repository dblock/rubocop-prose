# frozen_string_literal: true

module RuboCop
  module Cop
    module Prose
      class MaxLength < Base
        extend AutoCorrector

        MSG = 'Prose line is too long. [%<length>d/%<max>d]'
        UNWRAP_MSG = 'Keep paragraph text on a single source line.'

        def validate_config
          value = cop_config['Max']
          return if value == false || (value.is_a?(Integer) && value.positive?)

          raise ValidationError, 'Prose/MaxLength: Max must be a positive integer or false.'
        end

        private

        def investigate_paragraph(paragraph)
          return unwrap_paragraph(paragraph) if cop_config['Max'] == false

          document.line_numbers(paragraph).each { |number| inspect_line(paragraph, number) }
        end

        def unwrap_paragraph(paragraph)
          document.soft_breaks(paragraph).each do |number|
            previous = document.line(number)
            column = document.content_start(paragraph, number + 1)

            join = document.range(number, previous.rstrip.length, number + 1, column)
            offense = document.range(number + 1, column)
            prose_offense(offense, message: UNWRAP_MSG) do |corrector|
              corrector.replace(processed_range(join), ' ') if document.reflowable?(paragraph)
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
          breaks = if document.reflowable?(paragraph)
                     wrap_points(text, number, first, prefix, document.atomic_ranges(paragraph))
                   else
                     []
                   end
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
            next unless document.breakable_space?(text, match.begin(0), match.end(0))

            range = document.range(number, match.begin(0), number, match.end(0))
            spaces << range unless atomic.any? { |protected| protected.overlaps?(range) }
          end
          spaces
        end
      end
    end
  end
end
