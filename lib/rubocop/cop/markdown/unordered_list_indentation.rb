# frozen_string_literal: true

require_relative '../../prose/list_rules'

module RuboCop
  module Cop
    module Markdown
      class UnorderedListIndentation < Base
        include RuboCop::Prose::ListRules

        private

        def investigate_document
          width = cop_config.fetch('Indent', 2)
          list_groups do |list, marks, parent|
            next unless list.type == :ul

            expected = expected_indentation(parent, marks.first, width)
            marks.each do |mark|
              next if mark[:indent] == expected

              prose_offense(document.range(mark[:line], mark[:column], mark[:line], mark[:column] + 1),
                            message: "Use #{expected} spaces of unordered list indentation.")
            end
          end
        end

        def expected_indentation(parent, mark, width)
          return 0 unless parent && parent[:quote_depth] == mark[:quote_depth]

          width = [width, parent[:content_column] - parent[:column]].max if parent[:marker].length > 1
          parent[:indent] + width
        end
      end
    end
  end
end
