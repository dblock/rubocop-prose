# frozen_string_literal: true

require_relative '../../prose/table_rules'

module RuboCop
  module Cop
    module Markdown
      class TablePipes < Prose::Base
        extend AutoCorrector

        def investigate_document
          RuboCop::Prose::TableRules.tables(document).each do |table|
            style = cop_config.fetch('Style', 'consistent')
            expected = case style
                       when 'leading_and_trailing' then [true, true]
                       when 'leading_only' then [true, false]
                       when 'trailing_only' then [false, true]
                       when 'no_leading_or_trailing' then [false, false]
                       else [table.rows.first.leading, table.rows.first.trailing]
                       end
            table.rows.each do |row|
              next if [row.leading, row.trailing] == expected

              range = document.range(row.number, row.begin_pos, row.number, row.end_pos)
              prose_offense(range, message: 'Use consistent leading and trailing table pipes.') do |corrector|
                replacement = row.text[row.begin_pos...row.end_pos].dup
                replacement = replacement[1..] if row.leading && !expected[0]
                replacement = replacement[0...-1] if row.trailing && !expected[1]
                replacement = "|#{replacement}" if !row.leading && expected[0]
                replacement = "#{replacement}|" if !row.trailing && expected[1]
                # Without an outer pipe, an empty boundary cell is indistinguishable
                # from an outer pipe; leaving it alone preserves the column count.
                next if !expected[0] && row.cells.first.text.strip.empty?
                next if !expected[1] && row.cells.last.text.strip.empty?
                next if expected.none? && row.cells.length == 1

                corrector.replace(processed_range(range), replacement)
              end
            end
          end
        end
      end
    end
  end
end
