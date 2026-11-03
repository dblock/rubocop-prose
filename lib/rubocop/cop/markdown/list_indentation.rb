# frozen_string_literal: true

require_relative '../../prose/list_rules'

module RuboCop
  module Cop
    module Markdown
      class ListIndentation < Prose::Base
        include RuboCop::Prose::ListRules

        private

        def investigate_document
          list_groups do |_list, marks, _parent|
            expected = marks.first[:indent]
            marks.drop(1).each do |mark|
              next if mark[:indent] == expected

              prose_offense(document.range(mark[:line], mark[:column], mark[:line],
                                           mark[:column] + mark[:marker].length),
                            message: "Align sibling list markers at indentation #{expected}.")
            end
          end
        end
      end
    end
  end
end
