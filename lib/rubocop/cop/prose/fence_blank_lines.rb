# frozen_string_literal: true

require_relative '../../prose/code_rules'

module RuboCop
  module Cop
    module Prose
      class FenceBlankLines < Base
        extend AutoCorrector
        include RuboCop::Prose::CodeRules

        private

        def investigate_document
          @insertions = Set.new
          code_blocks.each do |node|
            next if !cop_config.fetch('ListItems', true) &&
                    code_ancestors(node).any? { |ancestor| ancestor.type == :li }

            details = fence_details(node)
            next unless details

            first = details[:first]
            last = details[:last]
            prefix = code_continuation_prefix(details[:opening][:prefix]).rstrip
            inline_item = details[:opening][:prefix].match?(/[-+*]|\d+[.)]/)
            unless inline_item || code_blank?(first - 1) || document.front_matter_line?(first - 1)
              add_blank(first, prefix)
            end
            add_blank(last + 1, prefix) unless code_blank?(last + 1)
          end
        end

        def add_blank(number, prefix)
          return unless @insertions.add?(number)

          range = document.line_range(number)
          prose_offense(range, message: 'Surround fenced code blocks with blank lines.') do |corrector|
            corrector.insert_before(processed_range(range), "#{prefix}\n")
          end
        end
      end
    end
  end
end
