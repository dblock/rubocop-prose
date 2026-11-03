# frozen_string_literal: true

require_relative '../../prose/list_rules'

module RuboCop
  module Cop
    module Markdown
      class ListBlankLines < Base
        extend AutoCorrector
        include RuboCop::Prose::ListRules

        private

        def investigate_document
          @insertions = Set.new
          list_groups do |list, marks, parent|
            next if parent

            first = marks.first[:line]
            last = node_last_line(list)
            prefix = continuation_prefix(document.line(first)[0...marks.first[:column]])
            add_boundary(first, prefix) unless container_blank?(first - 1) || document.front_matter_line?(first - 1)
            add_boundary(last + 1, prefix) unless container_blank?(last + 1)
          end
        end

        def add_boundary(number, prefix)
          return unless @insertions.add?(number)

          range = document.line_range(number)
          prose_offense(range, message: 'Surround lists with blank lines.') do |corrector|
            corrector.insert_before(processed_range(range), "#{prefix.rstrip}\n")
          end
        end
      end
    end
  end
end
