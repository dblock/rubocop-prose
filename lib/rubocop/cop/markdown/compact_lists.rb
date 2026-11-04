# frozen_string_literal: true

require_relative '../../prose/list_rules'

module RuboCop
  module Cop
    module Markdown
      class CompactLists < Base
        extend AutoCorrector
        include RuboCop::Prose::ListRules

        private

        def investigate_document
          list_groups do |list, marks, _parent|
            items = list.children.select { |child| child.type == :li }
            next unless marks.length == items.length

            marks.each_cons(2) do |previous, following|
              first_blank = node_last_line(previous[:item]) + 1
              last_blank = following[:line] - 1
              next unless first_blank <= last_blank

              blank_lines = (first_blank..last_blank).to_a
              next unless blank_lines.all? { |number| container_blank?(number) }

              range = document.range(first_blank, 0, following[:line], 0)
              prose_offense(range, message: 'Avoid blank lines between list items.') do |corrector|
                next unless simple_list_item?(previous[:item]) && simple_list_item?(following[:item])

                corrector.remove(processed_range(range))
              end
            end
          end
        end

        def simple_list_item?(item)
          item.children.one? && item.children.first.type == :p
        end
      end
    end
  end
end
