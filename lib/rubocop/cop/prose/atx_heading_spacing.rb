# frozen_string_literal: true

require_relative '../../prose/heading_rules'

module RuboCop
  module Cop
    module Prose
      class AtxHeadingSpacing < Base
        extend AutoCorrector
        include RuboCop::Prose::HeadingRules

        def investigate_document
          heading_entries.each do |heading|
            opening = heading[:opening]
            next unless opening && (spacing = /\A[ \t]{2,}(?=\S)/.match(opening[:rest]))

            column = opening.begin(:rest)
            range = document.range(heading[:line], column, heading[:line], column + spacing[0].length)
            prose_offense(range, message: 'Use one space after opening heading hashes.') do |corrector|
              corrector.replace(processed_range(range), ' ')
            end
          end
        end
      end
    end
  end
end
