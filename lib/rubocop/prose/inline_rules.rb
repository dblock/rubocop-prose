# frozen_string_literal: true

module RuboCop
  module Prose
    # Source positions are character offsets, like Document#range.
    module InlineRules
      Span = Struct.new(:begin_pos, :end_pos, :kind, :delimiter, keyword_init: true)

      class PositionedParser < Parser
        protected

        def parse_emphasis
          scanner = @src
          parent = @tree
          count = parent.children.length
          first = scanner.pos
          number = scanner.current_line_number
          super
          node = parent.children.last
          return unless parent.children.length > count && %i[em strong].include?(node.type)

          node.options[:prose_delimiters] = [scanner.string, first, scanner.pos, number]
        end
      end

      def self.lines(document)
        found = {}
        document.paragraphs.each do |paragraph|
          document.line_numbers(paragraph).each do |number|
            found[number] = document.content_start(paragraph, number)
          end
        end
        document.nodes(:header).each { |node| found[node.options[:location]] = 0 }
        document.nodes(:table).each do |node|
          number = node.options[:location]
          while number <= document.lines.length && !document.line(number).strip.empty?
            found[number] = 0
            number += 1
          end
        end
        found.sort.filter_map do |number, column|
          next if document.code_line?(number) || document.front_matter_line?(number)

          [document.line(number), number, column]
        end
      end

      def self.escaped?(text, index)
        count = 0
        index -= 1
        while index >= 0 && text[index] == '\\'
          count += 1
          index -= 1
        end
        count.odd?
      end

      def self.spans(text, links: true, html: true)
        result = []
        index = 0
        while (index = text.index(/[\\`<!\[]/, index))
          if text[index] == '\\' && text[index + 1]&.match?(/[[:punct:]]/)
            result << Span.new(begin_pos: index, end_pos: [index + 2, text.length].min, kind: :escape)
            index += 2
            next
          end
          if text[index] == '`'
            delimiter = text[index..][/\A`+/]
            finish = index + delimiter.length
            closed = false
            while (match = /`+/.match(text, finish))
              if match[0] == delimiter
                result << Span.new(begin_pos: index, end_pos: match.end(0), kind: :code, delimiter: delimiter)
                index = match.end(0)
                closed = true
                break
              end
              finish = match.end(0)
            end
            next if closed

            index += delimiter.length
            next
          elsif html && text[index] == '<'
            rest = text[index..]
            html = %r{\A<([A-Za-z][\w:-]*)\b[^>]*>.*?</\1\s*>}i.match(rest) ||
                   /\A(?:<!--.*?-->|<[^>]+>)/.match(rest)
            if html
              result << Span.new(begin_pos: index, end_pos: index + html[0].length, kind: :html)
              index += html[0].length
              next
            end
          elsif links && (text[index] == '[' || (text[index] == '!' && text[index + 1] == '['))
            finish = link_end(text, index)
            if finish
              result << Span.new(begin_pos: index, end_pos: finish, kind: :link)
              index = finish
              next
            end
          end
          index += 1
        end
        result
      end

      def self.link_end(text, index)
        index += 1 if text[index] == '!'
        close = balanced_end(text, index, '[', ']')
        return unless close
        return balanced_end(text, close, '(', ')') if text[close] == '('
        return balanced_end(text, close, '[', ']') if text[close] == '['

        # A shortcut reference may resolve elsewhere in the document.
        close
      end

      def self.balanced_end(text, index, opening, closing)
        depth = 0
        (index...text.length).each do |position|
          next if escaped?(text, position)

          depth += 1 if text[position] == opening
          depth -= 1 if text[position] == closing
          return position + 1 if depth.zero?
        end
        nil
      end

      def self.multiline_atoms(document)
        document.multiline_atoms
      end

      def self.mask(text, include_code: false, document: nil, number: nil)
        result = text.dup
        spans(text).each do |span|
          next if include_code && span.kind == :code

          result[span.begin_pos...span.end_pos] = ' ' * (span.end_pos - span.begin_pos)
        end
        if document
          line = document.line_range(number)
          multiline_atoms(document).each do |range|
            next if include_code && range.source.start_with?('`')
            next unless range.overlaps?(line)

            first = [range.begin_pos, line.begin_pos].max - line.begin_pos
            last = [range.end_pos, line.end_pos].min - line.begin_pos
            result[first...last] = ' ' * (last - first)
          end
        end
        result
      end

      def self.emphasis(document)
        source = document.source.dup
        document.lines.each_with_index do |_, index|
          next unless document.front_matter_line?(index + 1)

          range = document.buffer.line_range(index + 1)
          source[range.begin_pos...range.end_pos] = ' ' * range.size
        end
        root = PositionedParser.parse(source, hard_wrap: false, gfm_quirks: %i[paragraph_end no_auto_typographic]).first
        nodes = lambda do |node|
          [node] + (node.type == :table ? [] : node.children.flat_map { |child| nodes.call(child) })
        end
        records = nodes.call(root).map { |node| [node, 0, nil] }
        document.nodes(:table).each do |table|
          number = table.options[:location]
          while number <= document.lines.length && !document.line(number).strip.empty?
            # Cell locations are not document-relative; parsing the row as inline prose
            # recovers offsets without changing the table parser or its AST.
            row = PositionedParser.parse("prose #{document.line(number).tr('|', ';')}",
                                         hard_wrap: false, gfm_quirks: %i[paragraph_end no_auto_typographic]).first
            records.concat(nodes.call(row).map { |node| [node, number - 1, -6] })
            number += 1
          end
        end
        ranges = { em: [], strong: [] }
        source_lines = {}.compare_by_identity
        records.each do |node, line_offset, column_offset|
          next unless ranges.key?(node.type) && node.options[:prose_delimiters]

          text, first, last, number = node.options[:prose_delimiters]
          next unless number

          number += line_offset
          before = text.byteslice(0, first)
          through = text.byteslice(0, last)
          local_line = before.count("\n")
          last_number = number + through.count("\n") - local_line
          lines = source_lines[text] ||= text.lines(chomp: true)
          first_text = lines[local_line]
          last_text = lines[through.count("\n")]
          first_prefix = column_offset || document.line(number).rindex(first_text)
          last_prefix = column_offset || document.line(last_number).rindex(last_text)
          next unless first_prefix && last_prefix

          column = first_prefix + before.rpartition("\n").last.length
          last_column = last_prefix + through.rpartition("\n").last.length
          next if spans(document.line(number)).any? { |span| span.begin_pos <= column && span.end_pos > column }

          position = document.range(number, column, number, column + 1)
          next if multiline_atoms(document).any? { |range| range.contains?(position) }

          width = node.type == :strong ? 2 : 1
          ranges.fetch(node.type) << [
            document.range(number, column, number, column + width),
            document.range(last_number, last_column - width, last_number, last_column), node.options[:char]
          ]
        end
        ranges.transform_values { |entries| entries.sort_by { |opening, _, _| opening.begin_pos } }
      end
    end
  end
end
