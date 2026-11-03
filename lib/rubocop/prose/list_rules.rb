# frozen_string_literal: true

module RuboCop
  module Prose
    # Source positions come from parsed list items, not marker-shaped prose.
    module ListRules
      def list_groups(node = document.root, parent = nil, &block)
        if %i[ul ol].include?(node.type)
          items = node.children.select { |child| child.type == :li }
          marks = items.filter_map { |item| list_marker(item, parent) }
          yield node, marks, parent unless marks.empty?
          items.each do |item|
            mark = list_marker(item, parent)
            item.children.each { |child| list_groups(child, mark, &block) }
          end
        else
          node.children.each { |child| list_groups(child, parent, &block) }
        end
      end

      def list_marker(item, parent)
        number = item.options[:location]
        text = document.line(number)
        offset = parent && parent[:line] == number ? parent[:content_column] : 0
        match = /\G(?<prefix>(?:[ \t]*>[ \t]?)*[ \t]*)(?<marker>[-+*]|\d+[.)])(?<gap>[ \t]+|$)/.match(text, offset)
        return unless match && match.begin(0) == offset

        column = match.begin(:marker)
        prefix = text[0...column]
        quote = prefix.rindex('>')
        quote = if quote
                  quote + 1 + (prefix[quote + 1]&.match?(/[ \t]/) ? 1 : 0)
                else
                  0
                end
        { item: item, line: number, column: column, marker: match[:marker],
          gap: match[:gap], content_column: match.end(0), indent: column - quote,
          quote_depth: prefix.count('>') }
      end

      def node_last_line(node)
        first = node.options[:location] || 0
        own = if node.type == :codeblock
                first + node.value.lines.length + (node.options[:fenced] ? 1 : -1)
              elsif node.options[:prose_source]
                first + node.options[:prose_source].lines.length - 1
              elsif node.value.is_a?(String) && first.positive?
                first + [node.value.lines.length - 1, 0].max
              else
                first
              end
        [own, *node.children.map { |child| node_last_line(child) }].max
      end

      def container_blank?(number)
        number < 1 || number > document.lines.length ||
          document.line(number).match?(/\A[ \t]*(?:>[ \t]*)*\z/)
      end

      def continuation_prefix(text)
        text.gsub(/[-+*]|\d+[.)]/) { |marker| ' ' * marker.length }
      end
    end
  end
end
