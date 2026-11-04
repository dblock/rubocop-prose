# frozen_string_literal: true

require_relative '../../prose/structural_blank_lines'
require_relative '../../prose/list_rules'

module RuboCop
  module Cop
    module Prose
      class MultipleBlankLines < Base
        extend AutoCorrector
        include RuboCop::Prose::ListRules

        def validate_config
          value = cop_config['Max']
          return if value.is_a?(Integer) && value >= 0

          raise ValidationError, 'Prose/MultipleBlankLines: Max must be a non-negative integer.'
        end

        private

        def investigate_document
          consecutive = 0
          sequence = nil
          quote_blank_lines = markdown_quote_blank_lines
          source_lines = document.source.lines
          protected_lines = structural_blank_lines
          document.lines.each_with_index do |text, index|
            number = index + 1
            quote = quote_blank_lines[number]
            blank = quote || (text.strip.empty? && :root)
            if document.ignored_line?(number) || !blank
              consecutive = 0
              sequence = nil
              next
            end
            if sequence != blank
              consecutive = 0
              sequence = blank
            end
            consecutive += 1
            next if consecutive <= cop_config['Max'] || protected_lines.include?(number)

            first = document.buffer.line_range(number).begin_pos
            removal = ::Parser::Source::Range.new(document.buffer, first, first + source_lines.fetch(index).length)
            prose_offense(document.line_range(number), message: 'Too many consecutive blank lines.') do |corrector|
              corrector.remove(processed_range(removal)) if cop_config['Max'].positive?
            end
          end
        end

        def structural_blank_lines
          return Set.new unless processed_source.prose_format == :markdown

          RuboCop::Prose::StructuralBlankLines.new(document, config, processed_source).protected_lines
        end

        def markdown_quote_blank_lines
          return {} unless document.is_a?(RuboCop::Prose::MarkdownDocument)

          quote_blank_lines_in(document.root, nil, 0, {})
        end

        def quote_blank_lines_in(node, quote, depth, lines)
          if node.type == :blockquote
            quote = node
            depth += 1
          end

          if quote
            node.children.each_with_index do |child, index|
              next unless child.type == :blank

              previous = node.children[0...index].reverse.find { |sibling| sibling.type != :blank }
              following = node.children[(index + 1)..].find { |sibling| sibling.type != :blank }
              next unless previous && following && following.options[:location]

              ((node_last_line(previous) + 1)...following.options[:location]).each do |number|
                lines[number] = quote if quoted_blank_line?(number, depth)
              end
            end
          end

          node.children.each { |child| quote_blank_lines_in(child, quote, depth, lines) }
          lines
        end

        def quoted_blank_line?(number, depth)
          text = document.line(number)
          prefix = text[/\A[ \t]*(?:>[ \t]*)+/]
          prefix && prefix.count('>') == depth && text[prefix.length..].strip.empty?
        end
      end
    end
  end
end
