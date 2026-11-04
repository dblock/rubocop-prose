# frozen_string_literal: true

module RuboCop
  module Prose
    module HeadingRules
      # Container markers are retained so source columns refer to the original line.
      ATX = /\A(?<prefix>(?: {0,3}>[ \t]?| {0,3}(?:[-+*]|\d+[.)])[ \t]+)* {0,3})(?<marks>\#{1,6})(?!#)(?<rest>.*)\z/

      def heading_entries
        document.nodes(:header).map do |node|
          number = node.options.fetch(:location)
          text = document.line(number)
          opening = ATX.match(text)
          closing = opening && closing_heading_match(opening[:rest])
          {
            level: node.options.fetch(:level), text: document.plain_text(node), line: number,
            last_line: opening ? number : number + 1, opening: opening, closing: closing,
            style: if opening
                     closing ? 'atx_closed' : 'atx'
                   else
                     'setext'
                   end
          }
        end
      end

      def closing_heading_match(rest)
        match = /(?<space>[ \t]+)(?<marks>#+)[ \t]*\z/.match(rest)
        return match if match

        /\A(?<space>)(?<marks>#+)[ \t]*\z/.match(rest)
      end

      def heading_candidates
        document.prose_lines.filter_map do |text, number|
          match = ATX.match(text)
          [match, number] if match
        end
      end

      def heading_range(entry)
        document.line_range(entry.fetch(:line))
      end

      def heading_blank?(number)
        document.line(number).match?(/\A(?: {0,3}>[ \t]?)*[ \t]*\z/)
      end

      def heading_end_range
        ::Parser::Source::Range.new(document.buffer, document.source.length, document.source.length)
      end
    end
  end
end
