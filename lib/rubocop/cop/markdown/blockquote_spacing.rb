# frozen_string_literal: true

require_relative '../../prose/list_rules'

module RuboCop
  module Cop
    module Markdown
      class BlockquoteSpacing < Prose::Base
        extend AutoCorrector
        include RuboCop::Prose::ListRules

        private

        def investigate_document
          quote_lines = document.nodes(:blockquote).flat_map do |node|
            (node.options[:location]..node_last_line(node)).to_a
          end.to_set
          list_lines = []
          list_groups do |_list, marks, _parent|
            marks.each { |mark| list_lines.concat((mark[:line]..node_last_line(mark[:item])).to_a) }
          end
          document.prose_lines do |text, number|
            next unless quote_lines.include?(number)

            prefix = text[/\A[ \t]*(?:>[ \t]*)+/]
            next unless prefix

            prefix.to_enum(:scan, />[ \t]{2,}/).each do
              match = Regexp.last_match
              next if match.end(0) == prefix.length && (list_lines.include?(number) || text[prefix.length..].empty?)

              range = document.range(number, match.begin(0) + 1, number, match.end(0))
              prose_offense(range, message: 'Use one space after a blockquote marker.') do |corrector|
                corrector.replace(processed_range(range), ' ')
              end
            end
          end
        end
      end
    end
  end
end
