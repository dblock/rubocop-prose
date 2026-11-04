# frozen_string_literal: true

require_relative '../../prose/list_rules'

module RuboCop
  module Cop
    module Markdown
      class BlockquoteSpacing < Base
        extend AutoCorrector
        include RuboCop::Prose::ListRules

        private

        def investigate_document
          quote_depths = Hash.new(0)
          document.nodes(:blockquote).each do |node|
            (node.options[:location]..node_last_line(node)).each { |number| quote_depths[number] += 1 }
          end
          list_lines = []
          list_groups do |_list, marks, _parent|
            marks.each { |mark| list_lines.concat((mark[:line]..node_last_line(mark[:item])).to_a) }
          end
          document.prose_lines do |text, number|
            next unless quote_depths[number].positive?

            prefix = text[/\A[ \t]*(?:>[ \t]*)+/]
            next unless prefix

            markers = prefix.to_enum(:scan, />/).map { Regexp.last_match.begin(0) }
            prefix.to_enum(:scan, />[ \t]{2,}/).each do
              match = Regexp.last_match
              next if match.end(0) == prefix.length && (list_lines.include?(number) || text[prefix.length..].empty?)

              range = document.range(number, match.begin(0) + 1, number, match.end(0))
              prose_offense(range, message: 'Use one space after a blockquote marker.') do |corrector|
                corrector.replace(processed_range(range), ' ')
              end
            end

            next unless markers.length == quote_depths[number]

            markers.each do |column|
              next if text[column + 1]&.match?(/[ \t]/)
              next if text[(column + 1)..].sub(/\A(?:[ \t]*>)*[ \t]*/, '').empty?

              range = document.range(number, column, number, column + 1)
              prose_offense(range, message: 'Use one space after a blockquote marker.') do |corrector|
                next unless correction_preserves_structure?(number, column)

                corrector.insert_after(processed_range(range), ' ')
              end
            end
          end
        end

        def correction_preserves_structure?(number, column)
          source = document.source.dup
          line_start = document.buffer.line_range(number).begin_pos
          position = source.byteslice(0, line_start).length + column + 1
          source.insert(position, ' ')
          candidate = RuboCop::Prose::MarkdownDocument.new(
            ::Parser::Source::Buffer.new(document.buffer.name, source: source),
            configuration: config
          )
          tree_signature(document.root) == tree_signature(candidate.root) &&
            document.warnings == candidate.warnings
        end

        def tree_signature(node)
          options = node.options.except(:prose_lines, :original_ranges)
          [node.type, node.value, options, node.children.map { |child| tree_signature(child) }]
        end
      end
    end
  end
end
