# frozen_string_literal: true

require_relative '../../prose/inline_rules'

module RuboCop
  module Cop
    module Prose
      class ProperNames < Base
        extend AutoCorrector

        def investigate_document
          names = Array(cop_config['Names']).reject(&:empty?)
          return if names.empty?

          alternatives = names.sort_by { |name| -name.length }.map { |name| Regexp.escape(name) }.join('|')
          pattern = /(?<![\p{L}\p{N}_])(?:#{alternatives})(?![\p{L}\p{N}_])/i
          markdown = processed_source.prose_format == :markdown
          name_lines.each do |text, number, column|
            masked = markdown ? masked_markdown_line(text, number) : text
            masked.to_enum(:scan, pattern).each do
              match = Regexp.last_match
              next if match.begin(0) < column

              expected = names.find { |name| name.casecmp?(match[0]) }
              next if match[0] == expected

              range = document.range(number, match.begin(0), number, match.end(0))
              prose_offense(range, message: "Use the capitalization `#{expected}`.") do |corrector|
                corrector.replace(processed_range(range), expected)
              end
            end
          end
        end

        private

        def name_lines
          return document.lines.each_with_index.map { |text, index| [text, index + 1, 0] } unless
            processed_source.prose_format == :markdown

          lines = RuboCop::Prose::InlineRules.lines(document)
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
