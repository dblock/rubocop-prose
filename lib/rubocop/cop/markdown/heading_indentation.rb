# frozen_string_literal: true

require_relative '../../prose/heading_rules'

module RuboCop
  module Cop
    module Markdown
      class HeadingIndentation < Base
        include RuboCop::Prose::HeadingRules

        def investigate_document
          parsed_lines = heading_entries.to_set { |heading| heading[:line] }
          document.prose_lines.each do |text, number|
            next unless text.match?(/\A[ \t]+\S/)
            next unless parsed_lines.include?(number) || dedented_heading?(text, number)

            prose_offense(document.line_range(number), message: 'Start headings without leading indentation.')
          end
        end

        private

        def dedented_heading?(text, number)
          return false unless text.match?(/\A {1,3}\S/)

          source = "#{text.lstrip}\n"
          following = document.lines[number]
          if following&.match?(/\A {0,3}(?:=+|-+)[ \t]*\z/) && !document.code_line?(number + 1)
            source += "#{following.lstrip}\n"
          end
          root = RuboCop::Prose::Parser.parse(source).first
          root.children.any? { |node| node.type == :header }
        end
      end
    end
  end
end
