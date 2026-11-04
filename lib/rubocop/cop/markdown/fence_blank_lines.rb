# frozen_string_literal: true

require_relative '../../prose/code_rules'

module RuboCop
  module Cop
    module Markdown
      class FenceBlankLines < Base
        extend AutoCorrector
        include RuboCop::Prose::CodeRules

        def validate_config
          %w[LinesAbove LinesBelow].each do |name|
            value = cop_config.fetch(name, 1)
            next if value.is_a?(Integer) && value >= 0

            raise ValidationError, "Markdown/FenceBlankLines: #{name} must be a nonnegative integer."
          end
        end

        private

        def investigate_document
          @insertions = {}
          fenced_blocks(list_items: cop_config.fetch('ListItems', true)) do |details|
            first = details[:first]
            last = details[:last]
            prefix = code_continuation_prefix(details[:opening][:prefix]).rstrip
            inline_item = details[:opening][:prefix].match?(/[-+*]|\d+[.)]/)
            require_blanks(first, prefix, cop_config.fetch('LinesAbove', 1), -1) unless inline_item
            require_blanks(last + 1, prefix, cop_config.fetch('LinesBelow', 1), 1)
          end
          @insertions.each do |number, insertion|
            add_blank(number, insertion[:prefix], insertion[:count])
          end
        end

        def require_blanks(number, prefix, required, direction)
          return if required.zero?

          existing = blank_count(direction.negative? ? number - 1 : number, direction)
          missing = required - existing
          return unless missing.positive?

          # Adjacent fences must share one insertion, even when some padding already exists.
          number -= existing if direction.negative?
          insertion = @insertions[number] ||= { prefix: prefix, count: missing }
          insertion[:count] = [insertion[:count], missing].max
        end

        def blank_count(number, direction)
          count = 0
          while number.between?(1, document.lines.length)
            return Float::INFINITY if direction.negative? && document.front_matter_line?(number)
            break unless code_blank?(number)

            count += 1
            number += direction
          end
          number.between?(1, document.lines.length) ? count : Float::INFINITY
        end

        def add_blank(number, prefix, count)
          range = document.line_range(number)
          prose_offense(range, message: 'Surround fenced code blocks with blank lines.') do |corrector|
            corrector.insert_before(processed_range(range), "#{prefix}\n" * count)
          end
        end
      end
    end
  end
end
