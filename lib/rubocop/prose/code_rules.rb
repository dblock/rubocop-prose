# frozen_string_literal: true

module RuboCop
  module Prose
    module CodeRules
      def code_blocks
        document.nodes(:codeblock)
      end

      def fenced_blocks(list_items: true)
        return enum_for(__method__, list_items: list_items) unless block_given?

        code_blocks.each do |node|
          next if !list_items && code_ancestors(node).any? { |ancestor| ancestor.type == :li }

          details = fence_details(node)
          yield details if details
        end
      end

      def code_ancestors(target, node = document.root, parents = [])
        return parents if node.equal?(target)

        node.children.each do |child|
          found = code_ancestors(target, child, parents + [node])
          return found if found
        end
        nil
      end

      def fence_details(node)
        return unless node.options[:fenced]

        first = node.options[:location]
        opening = fence_match(document.line(first))
        return unless opening

        last = node.options.fetch(:code_start_line) + node.value.lines.length
        return if last > document.lines.length

        closing = fence_match(document.line(last))
        return unless closing && closing[:fence][0] == opening[:fence][0] &&
                      closing[:fence].length >= opening[:fence].length && closing[:info].strip.empty?

        { first: first, last: last, opening: opening, closing: closing }
      end

      def fence_match(text)
        /
          \A(?<prefix>(?:[ \t]*>[ \t]?|[ \t]*[-+*][ \t]+|[ \t]*\d+[.)][ \t]+|[ \t]+)*)
          (?<fence>`{3,}|~{3,})(?<info>.*)\z
        /x.match(text)
      end

      def fence_range(number, match)
        document.range(number, match.begin(:fence), number, match.end(:fence))
      end

      def code_blank?(number)
        number < 1 || number > document.lines.length ||
          document.line(number).match?(/\A[ \t]*(?:>[ \t]*)*\z/)
      end

      def code_continuation_prefix(prefix)
        prefix.gsub(/[-+*]|\d+[.)]/) { |marker| ' ' * marker.length }
      end

      def code_content_range(node, index, length)
        number = node.options.fetch(:code_start_line) + index
        content = node.value.lines[index].chomp
        raw = document.line(number)
        return unless raw.end_with?(content)

        first = raw.length - content.length
        document.range(number, first, number, first + length)
      end
    end
  end
end
