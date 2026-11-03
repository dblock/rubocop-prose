# frozen_string_literal: true

require_relative '../../prose/table_rules'

module RuboCop
  module Cop
    module Markdown
      class TableBlankLines < Base
        extend AutoCorrector

        def investigate_document
          RuboCop::Prose::TableRules.tables(document).each do |table|
            first = table.rows.first.number
            last = table.rows.last.number
            unless first == 1 || blank?(document.line(first - 1))
              range = document.range(first, 0, first, 0)
              prose_offense(document.line_range(first), message: 'Add a blank line before the table.') do |corrector|
                corrector.insert_before(processed_range(range), blank_prefix(document.line(first)) + newline)
              end
            end
            next if last == document.lines.length || blank?(document.line(last + 1))

            range = document.range(last + 1, 0, last + 1, 0)
            prose_offense(document.line_range(last), message: 'Add a blank line after the table.') do |corrector|
              corrector.insert_before(processed_range(range), blank_prefix(document.line(last)) + newline)
            end
          end
        end

        private

        def blank?(text)
          text.match?(/\A[ \t]*(?:>[ \t]*)*\z/)
        end

        def blank_prefix(text)
          text[/\A[ \t]*(?:>[ \t]*)+/].to_s.rstrip
        end

        def newline
          document.source.include?("\r\n") ? "\r\n" : "\n"
        end
      end
    end
  end
end
