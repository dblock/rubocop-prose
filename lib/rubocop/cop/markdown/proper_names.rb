# frozen_string_literal: true

require_relative '../../prose/inline_rules'
require_relative '../../prose/proper_name_rules'

module RuboCop
  module Cop
    module Markdown
      class ProperNames < Base
        include RuboCop::Prose::ProperNameRules
        extend AutoCorrector

        private

        def name_lines
          lines = document.inline_lines.map do |text, number, column|
            [masked_markdown_line(text, number), number, column]
          end
          return lines unless cop_config['CodeBlocks']

          document.nodes(:codeblock).each do |node|
            first = node.options.fetch(:code_start_line)
            node.value.lines.each_index do |index|
              number = first + index
              lines << [document.line(number), number, 0] unless document.front_matter_line?(number)
            end
          end
          lines
        end

        def masked_markdown_line(text, number)
          return text if document.code_line?(number)

          RuboCop::Prose::InlineRules.mask(text, include_code: cop_config['CodeBlocks'],
                                                 document: document, number: number)
        end
      end
    end
  end
end
