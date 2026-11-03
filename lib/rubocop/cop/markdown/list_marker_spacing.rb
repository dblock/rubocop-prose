# frozen_string_literal: true

require_relative '../../prose/list_rules'

module RuboCop
  module Cop
    module Markdown
      class ListMarkerSpacing < Prose::Base
        extend AutoCorrector
        include RuboCop::Prose::ListRules

        private

        def investigate_document
          list_groups do |list, marks, _parent|
            multiline = marks.any? { |mark| node_last_line(mark[:item]) > mark[:line] }
            key = "#{list.type == :ul ? 'Unordered' : 'Ordered'}#{multiline ? 'Multi' : 'Single'}"
            spaces = cop_config.fetch(key, 1)
            marks.each do |mark|
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
