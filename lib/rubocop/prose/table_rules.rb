# frozen_string_literal: true

require_relative 'inline_rules'

module RuboCop
  module Prose
    module TableRules
      Row = Struct.new(:number, :text, :begin_pos, :end_pos, :pipes, :cells, :leading, :trailing, keyword_init: true)
      Cell = Struct.new(:begin_pos, :end_pos, :text, keyword_init: true)
      Table = Struct.new(:rows, keyword_init: true)

      def self.row(document, number)
        return if number > document.lines.length || document.code_line?(number) || document.front_matter_line?(number)

        text = document.line(number)
        first = text[/\A[ \t]*(?:>[ \t]*)*/].length
        last = text.rstrip.length
        return if first >= last

        protected = InlineRules.spans(text, links: false, html: false)
        pipes = (first...last).select do |index|
          text[index] == '|' && protected.none? { |span| index >= span.begin_pos && index < span.end_pos }
        end
        leading = pipes.first == first
        trailing = pipes.last == last - 1
        boundaries = pipes.dup
        boundaries.shift if leading
        boundaries.pop if trailing
        start = leading ? first + 1 : first
        finish = trailing ? last - 1 : last
        cells = []
        boundaries.each do |position|
          cells << Cell.new(begin_pos: start, end_pos: position, text: text[start...position])
          start = position + 1
        end
        cells << Cell.new(begin_pos: start, end_pos: finish, text: text[start...finish])
        Row.new(number: number, text: text, begin_pos: first, end_pos: last, pipes: pipes, cells: cells,
                leading: leading, trailing: trailing)
      end

      def self.tables(document)
        # A malformed body can make GFM reject the entire table. Its header and delimiter
        # still identify the intended table, but only inside parser-recognized prose.
        eligible = document.inline_lines.to_set { |_, number, _| number }
        result = []
        number = 1
        while number < document.lines.length
          header = row(document, number) if eligible.include?(number)
          separator = row(document, number + 1) if header && !header.pipes.empty?
          if separator&.cells&.all? { |cell| cell.text.strip.match?(/\A:?-{3,}:?\z/) }
            rows = [header, separator]
            cursor = number + 2
            while cursor <= document.lines.length && eligible.include?(cursor)
              body = row(document, cursor)
              break unless body && !body.pipes.empty?

              rows << body
              cursor += 1
            end
            result << Table.new(rows: rows)
            number = cursor
          else
            number += 1
          end
          header = separator = nil
        end
        result
      end
    end
  end
end
