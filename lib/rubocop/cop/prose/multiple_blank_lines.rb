# frozen_string_literal: true

module RuboCop
  module Cop
    module Prose
      class MultipleBlankLines < Base
        extend AutoCorrector

        def validate_config
          value = cop_config['Max']
          return if value.is_a?(Integer) && value >= 0

          raise ValidationError, 'Prose/MultipleBlankLines: Max must be a non-negative integer.'
        end

        private

        def investigate_document
          consecutive = 0
          source_lines = document.source.lines
          document.lines.each_with_index do |text, index|
            number = index + 1
            if document.code_line?(number) || document.front_matter_line?(number) || !text.strip.empty?
              consecutive = 0
              next
            end
            consecutive += 1
            next if consecutive <= cop_config['Max']

            first = document.buffer.line_range(number).begin_pos
            removal = ::Parser::Source::Range.new(document.buffer, first, first + source_lines.fetch(index).length)
            prose_offense(document.line_range(number), message: 'Too many consecutive blank lines.') do |corrector|
              corrector.remove(processed_range(removal)) if cop_config['Max'].positive?
            end
          end
        end
      end
    end
  end
end
