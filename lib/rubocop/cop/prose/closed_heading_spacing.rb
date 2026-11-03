# frozen_string_literal: true

require_relative '../../prose/heading_rules'

module RuboCop
  module Cop
    module Prose
      class ClosedHeadingSpacing < Base
        extend AutoCorrector
        include RuboCop::Prose::HeadingRules

        def investigate_document
          heading_entries.each do |heading|
            closing = heading[:closing]
            next unless closing && closing[:space].length > 1

            column = heading[:opening].begin(:rest) + closing.begin(:space)
            range = document.range(heading[:line], column, heading[:line], column + closing[:space].length)
            prose_offense(range, message: 'Use one space before closing heading hashes.') do |corrector|
              corrector.replace(processed_range(range), ' ')
            end
          end
        end
      end
    end
  end
end
