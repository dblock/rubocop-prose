# frozen_string_literal: true

require_relative '../../prose/list_rules'

module RuboCop
  module Cop
    module Markdown
      class OrderedListNumbering < Prose::Base
        extend AutoCorrector
        include RuboCop::Prose::ListRules

        private

        def investigate_document
          list_groups do |list, marks, _parent|
            next unless list.type == :ol

            first = marks.first[:marker].to_i
            marks.each_with_index do |mark, index|
              expected = cop_config.fetch('EnforcedStyle', 'sequential') == 'ones' ? 1 : first + index
              digits = mark[:marker][/\A\d+/]
              next if digits == expected.to_s

              range = document.range(mark[:line], mark[:column], mark[:line], mark[:column] + digits.length)
              prose_offense(range, message: "Use #{expected} for this ordered list item.") do |corrector|
                # Changing marker width can change continuation-block indentation.
                corrector.replace(processed_range(range), expected.to_s) if digits.length == expected.to_s.length
              end
            end
          end
        end
      end
    end
  end
end
