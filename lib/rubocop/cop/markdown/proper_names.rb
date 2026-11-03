# frozen_string_literal: true

require_relative '../../prose/inline_rules'

module RuboCop
  module Cop
    module Markdown
      class ProperNames < Prose::Base
        extend AutoCorrector

        def investigate_document
          names = Array(cop_config['Names']).reject(&:empty?)
          return if names.empty?

          alternatives = names.sort_by { |name| -name.length }.map { |name| Regexp.escape(name) }.join('|')
          pattern = /(?<![\p{L}\p{N}_])(?:#{alternatives})(?![\p{L}\p{N}_])/i
          lines = RuboCop::Prose::InlineRules.lines(document)
          if cop_config['CodeBlocks']
            document.nodes(:codeblock).each do |node|
              first = node.options.fetch(:code_start_line)
              node.value.lines.each_index do |index|
                number = first + index
                lines << [document.line(number), number, 0] unless document.front_matter_line?(number)
              end
            end
          end
          lines.each do |text, number, column|
            masked = if document.code_line?(number)
                       text
                     else
                       RuboCop::Prose::InlineRules.mask(text, include_code: cop_config['CodeBlocks'],
                                                              document: document, number: number)
                     end
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
      end
    end
  end
end
