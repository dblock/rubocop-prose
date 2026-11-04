# frozen_string_literal: true

require_relative '../../prose/structural_blank_lines'

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
          protected_lines = structural_blank_lines
          document.lines.each_with_index do |text, index|
            number = index + 1
            if document.ignored_line?(number) || !text.strip.empty?
              consecutive = 0
              next
            end
            consecutive += 1
            next if consecutive <= cop_config['Max'] || protected_lines.include?(number)

            first = document.buffer.line_range(number).begin_pos
            removal = ::Parser::Source::Range.new(document.buffer, first, first + source_lines.fetch(index).length)
            prose_offense(document.line_range(number), message: 'Too many consecutive blank lines.') do |corrector|
              corrector.remove(processed_range(removal)) if cop_config['Max'].positive?
            end
          end
        end

        def structural_blank_lines
          return Set.new unless processed_source.prose_format == :markdown

          RuboCop::Prose::StructuralBlankLines.new(document, config, processed_source).protected_lines
        end
      end
    end
  end
end
