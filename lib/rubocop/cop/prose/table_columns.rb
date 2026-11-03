# frozen_string_literal: true

require_relative '../../prose/table_rules'

module RuboCop
  module Cop
    module Prose
      class TableColumns < Base
        def investigate_document
          RuboCop::Prose::TableRules.tables(document).each do |table|
            count = table.rows.first.cells.length
            table.rows.drop(1).each do |row|
              next if row.cells.length == count

              prose_offense(document.range(row.number, row.begin_pos, row.number, row.end_pos),
                            message: "Expected #{count} table columns, found #{row.cells.length}.")
            end
          end
        end
      end
    end
  end
end
