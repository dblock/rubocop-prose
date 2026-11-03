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

            expected = parent && parent[:quote_depth] == marks.first[:quote_depth] ? parent[:indent] + width : 0
            marks.each do |mark|
              next if mark[:indent] == expected

              prose_offense(document.range(mark[:line], mark[:column], mark[:line], mark[:column] + 1),
                            message: "Use #{expected} spaces of unordered list indentation.")
            end
          end
        end
      end
    end
  end
end
