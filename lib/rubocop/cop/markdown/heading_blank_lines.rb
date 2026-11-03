# frozen_string_literal: true

require_relative '../../prose/heading_rules'

module RuboCop
  module Cop
    module Markdown
      class HeadingBlankLines < Base
        include RuboCop::Prose::HeadingRules

        def investigate_document
          heading_entries.each do |heading|
            before = blank_count(heading[:line] - 1, -1)
            after = blank_count(heading[:last_line] + 1, 1)
            next unless before < cop_config.fetch('LinesAbove', 1) || after < cop_config.fetch('LinesBelow', 1)

            prose_offense(heading_range(heading), message: 'Surround headings with the configured blank lines.')
          end
        end

        private

        def blank_count(number, direction)
          count = 0
          while number.between?(1, document.lines.length)
            return Float::INFINITY if document.front_matter_line?(number) && direction.negative?
            break unless document.line(number).match?(/\A(?: {0,3}>[ \t]?)*[ \t]*\z/)

            count += 1
            number += direction
          end
          number.between?(1, document.lines.length) ? count : Float::INFINITY
        end
      end
    end
  end
end
