# frozen_string_literal: true

require_relative '../../prose/list_rules'

module RuboCop
  module Cop
    module Markdown
      class ListContinuationIndentation < Base
        include RuboCop::Prose::ListRules

        private

        def investigate_document
          list_groups do |_list, marks, _parent|
            marks.each do |mark|
              item_paragraphs(mark[:item]).each do |paragraph|
                investigate_continuations(mark, paragraph)
              end
            end
          end
        end

        def item_paragraphs(node)
          return [] if %i[ul ol].include?(node.type)
          return [node] if node.type == :p && node.options[:prose_source]

          node.children.flat_map { |child| item_paragraphs(child) }
        end

        def investigate_continuations(mark, paragraph)
          lines = document.line_numbers(paragraph).to_a
          return if lines.length < 2

          first_line = lines.first
          expected = [mark[:content_column], paragraph_content_column(paragraph, first_line)].max
          lines.drop(1).each do |number|
            next if multiline_atom_line?(number)

            actual = paragraph_content_column(paragraph, number)
            next unless actual < expected
            next if document.line(number)[actual..].empty?

            range = document.range(number, actual, number, actual + 1)
            prose_offense(range, message: "Indent list continuation text to column #{expected}.")
          end
        end

        def paragraph_content_column(paragraph, number)
          source_line = paragraph.options[:prose_source].split("\n", -1).fetch(number - paragraph.options[:location])
          document.content_start(paragraph, number) + source_line[/\A[ \t]*/].length
        end

        def multiline_atom_line?(number)
          document.multiline_atoms.any? { |atom| number.between?(atom.line, atom.last_line) }
        end
      end
    end
  end
end
