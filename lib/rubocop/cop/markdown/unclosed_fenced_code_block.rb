# frozen_string_literal: true

module RuboCop
  module Cop
    module Markdown
      class UnclosedFencedCodeBlock < Base
        private

        def investigate_document
          opening = nil
          document.lines.each_with_index do |line, index|
            number = index + 1
            next if document.front_matter_line?(number)

            match = fence_line(line)
            next unless match

            if opening
              opening = nil if closing_fence?(match, opening)
            elsif opening_fence?(match)
              opening = match.merge(line: number)
            end
          end
          report_unclosed(opening) if opening
        end

        def fence_line(line)
          index = 0
          quote_depth = 0
          list_indent = 0
          loop do
            start = index
            index += line[index..].to_s[/\A {0,3}/].length
            if line[index] == '>'
              quote_depth += 1
              index += 1
              index += 1 if [' ', "\t"].include?(line[index])
            elsif (list = /\A([-+*]|\d{1,9}[.)])([ \t]+)/.match(line[index..].to_s)) && list[2].length <= 4
              list_indent += index - start + list[1].length + list[2].length
              index += list[0].length
            else
              index = start
              break
            end
          end

          indent = line[index..].to_s[/\A {0,3}/].length
          index += indent
          fence = /\A(?<fence>`{3,}|~{3,})(?<info>.*)\z/.match(line[index..].to_s)
          return unless fence

          { column: index, fence: fence[:fence], info: fence[:info],
            quote_depth: quote_depth, list_indent: list_indent, indent: indent }
        end

        def opening_fence?(match)
          match[:fence][0] != '`' || !match[:info].include?('`')
        end

        def closing_fence?(match, opening)
          indent = match[:list_indent] + match[:indent]
          container_matches = if opening[:list_indent].zero?
                                match[:list_indent].zero? && indent <= 3
                              else
                                indent.between?(opening[:list_indent], opening[:list_indent] + 3)
                              end
          match[:fence][0] == opening[:fence][0] &&
            match[:fence].length >= opening[:fence].length &&
            match[:info].match?(/\A[ \t]*\z/) &&
            match[:quote_depth] == opening[:quote_depth] &&
            container_matches
        end

        def report_unclosed(opening)
          range = document.range(opening[:line], opening[:column],
                                 opening[:line], opening[:column] + opening[:fence].length)
          prose_offense(range, message: 'Close this fenced code block explicitly before end of file.')
        end
      end
    end
  end
end
