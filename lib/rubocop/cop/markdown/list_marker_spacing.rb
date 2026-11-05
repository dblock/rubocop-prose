# frozen_string_literal: true

require_relative '../../prose/list_rules'

module RuboCop
  module Cop
    module Markdown
      class ListMarkerSpacing < Base
        extend AutoCorrector
        include RuboCop::Prose::ListRules

        def validate_config
          unless %w[fixed aligned].include?(cop_config['Style'])
            raise ValidationError, "#{cop_name}: Style must be fixed or aligned."
          end
          return if cop_config['MinSpaces'].is_a?(Integer) && cop_config['MinSpaces'].positive?

          raise ValidationError, "#{cop_name}: MinSpaces must be a positive integer."
        end

        private

        def investigate_document
          list_groups do |_list, marks, _parent|
            widest = marks.map { |mark| mark[:marker].length }.max
            marks.each do |mark|
              spaces = cop_config['MinSpaces']
              spaces += widest - mark[:marker].length if cop_config['Style'] == 'aligned'
              next if mark[:gap].empty? || mark[:gap] == ' ' * spaces

              first = mark[:column] + mark[:marker].length
              range = document.range(mark[:line], first, mark[:line], mark[:content_column])
              prose_offense(range, message: "Use #{spaces} spaces after this list marker.") do |corrector|
                next unless spacing_correction_safe?(mark, spaces)

                corrector.replace(processed_range(range), ' ' * spaces)
              end
            end
          end
        end

        def spacing_correction_safe?(mark, spaces)
          item = mark[:item]
          return false unless node_last_line(item) == mark[:line]
          return false unless item.children.all? { |child| child.type == :p }

          content = document.line(mark[:line])[mark[:content_column]..]
          spaces.between?(1, 4) && !content.match?(/\A(?:[-+*]|\d+[.)]|>|`{3,}|~{3,}| {4})/)
        end
      end
    end
  end
end
