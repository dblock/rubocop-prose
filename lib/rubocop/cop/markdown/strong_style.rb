# frozen_string_literal: true

require_relative '../../prose/inline_rules'

module RuboCop
  module Cop
    module Markdown
      class StrongStyle < Prose::Base
        extend AutoCorrector

        def investigate_document
          expected = cop_config.fetch('Style', 'consistent')
          RuboCop::Prose::InlineRules.emphasis(document, :strong).each do |opening, closing, char|
            actual = char == '*' ? 'asterisk' : 'underscore'
            expected = actual if expected == 'consistent'
            next if actual == expected

            replacement = expected == 'asterisk' ? '**' : '__'
            before = opening.begin_pos.positive? ? document.source[opening.begin_pos - 1] : nil
            after = document.source[closing.end_pos]

            prose_offense(opening, message: "Use #{expected} strong emphasis.") do |corrector|
              next if replacement == '__' && (before&.match?(/[[:alnum:]_]/) || after&.match?(/[[:alnum:]_]/))

              corrector.replace(processed_range(opening), replacement)
              corrector.replace(processed_range(closing), replacement)
            end
          end
        end
      end
    end
  end
end
