# frozen_string_literal: true

require_relative '../../prose/heading_rules'

module RuboCop
  module Cop
    module Markdown
      class AtxHeadingSpace < Base
        include RuboCop::Prose::HeadingRules

        def investigate_document
          heading_candidates.each do |match, number|
            next if match[:rest].empty? || match[:rest].match?(/\A[ \t]/)

            prose_offense(document.line_range(number),
                          message: 'Separate opening heading hashes from text with a space.')
          end
        end
      end
    end
  end
end
