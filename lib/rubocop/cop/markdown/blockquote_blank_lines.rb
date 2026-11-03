# frozen_string_literal: true

require_relative '../../prose/list_rules'

module RuboCop
  module Cop
    module Markdown
      class BlockquoteBlankLines < Prose::Base
        extend AutoCorrector
        include RuboCop::Prose::ListRules

        private

        def investigate_document
          inspect_children(document.root)
        end

        def inspect_children(parent)
          previous = nil
          parent.children.each do |child|
            if child.type == :blockquote
              connect_quotes(previous, child) if previous
              previous = child
            elsif child.type != :blank
              previous = nil
            end
            inspect_children(child)
          end
        end

        def connect_quotes(first, last)
          start = last.options[:location]
          prefix = document.line(start)[/\A[ \t]*(?:>[ \t]*)+/]
          return unless prefix

          ((node_last_line(first) + 1)...start).each do |number|
            next unless container_blank?(number)

            range = document.line_range(number)
            prose_offense(range,
                          message: 'Keep blockquote markers on blank lines between quoted blocks.') do |corrector|
              corrector.replace(processed_range(range), prefix.rstrip)
            end
          end
        end
      end
    end
  end
end
