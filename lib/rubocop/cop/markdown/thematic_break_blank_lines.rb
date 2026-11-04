# frozen_string_literal: true

require_relative '../../prose/list_rules'

module RuboCop
  module Cop
    module Markdown
      class ThematicBreakBlankLines < Base
        extend AutoCorrector
        include RuboCop::Prose::ListRules

        THEMATIC_BREAK = /(?:\*[ \t]*){3,}|(?:-[ \t]*){3,}|(?:_[ \t]*){3,}/

        def validate_config
          %w[LinesAbove LinesBelow].each do |name|
            next unless cop_config.key?(name)

            value = cop_config[name]
            next if value.is_a?(Integer) && value >= 0

            raise ValidationError, "Markdown/ThematicBreakBlankLines: #{name} must be a nonnegative integer."
          end
        end

        private

        def investigate_document
          @insertions = {}
          document.nodes(:hr).each do |node|
            number = node.options.fetch(:location)
            next if document.front_matter_line?(number)

            marker = THEMATIC_BREAK.match(document.line(number))
            next unless marker

            ancestors = node_path(node)
            prefix = document.line(number)[0...marker.begin(0)]
            in_list = ancestors.any? { |ancestor| ancestor.type == :li }
            prefix = if in_list
                       continuation_prefix(prefix)
                     else
                       prefix.rstrip
                     end
            range = document.line_range(number)
            require_blanks(number - 1, -1, prefix, cop_config.fetch('LinesAbove', 1), range)
            require_blanks(number + 1, 1, prefix, cop_config.fetch('LinesBelow', 1), range)
          end

          @insertions.values.group_by { |insertion| insertion[:offense_range] }.each do |offense_range, insertions|
            if insertions.all? { |insertion| insertion[:safe] }
              prose_offense(offense_range, message: 'Surround thematic breaks with blank lines.') do |corrector|
                insertions.each do |insertion|
                  range = document.line_range(insertion[:line])
                  corrector.insert_before(processed_range(range), "#{insertion[:prefix]}#{newline}" * insertion[:count])
                end
              end
            else
              prose_offense(offense_range, message: 'Surround thematic breaks with blank lines.')
            end
          end
        end

        def require_blanks(number, direction, prefix, required, offense_range)
          return if required.zero?

          existing = blank_count(number, direction, prefix)
          missing = required - existing
          return unless missing.positive?

          insertion_line = direction.negative? ? number - existing + 1 : number
          insertion = @insertions[insertion_line] ||= {
            line: insertion_line, prefix: prefix, count: 0, offense_range: offense_range, safe: true
          }
          insertion[:count] = [insertion[:count], missing].max
          insertion[:safe] = false unless prefix == insertion[:prefix]
        end

        def blank_count(number, direction, prefix)
          count = 0
          while number.between?(1, document.lines.length)
            return Float::INFINITY if direction.negative? && document.front_matter_line?(number)
            break unless blank_line?(number, prefix)

            count += 1
            number += direction
          end
          number.between?(1, document.lines.length) ? count : Float::INFINITY
        end

        def blank_line?(number, prefix)
          text = document.line(number)
          return text.match?(/\A[ \t]*\z/) if prefix.empty?

          pattern = /\A#{Regexp.escape(prefix)}[ \t]*\z/
          text.match?(pattern)
        end

        def node_path(target, node = document.root, path = [])
          current_path = path + [node]
          return current_path if node.equal?(target)

          node.children.each do |child|
            found = node_path(target, child, current_path)
            return found if found
          end
          []
        end

        def newline
          document.source.include?("\r\n") ? "\r\n" : "\n"
        end
      end
    end
  end
end
