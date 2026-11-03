# frozen_string_literal: true

require_relative '../../prose/inline_rules'

module RuboCop
  module Cop
    module Prose
      class EmphasisSpacing < Base
        extend AutoCorrector

        def investigate_document
          RuboCop::Prose::InlineRules.lines(document).each do |text, number, column|
            masked = RuboCop::Prose::InlineRules.mask(text, document: document, number: number)
            masked.to_enum(:scan, /(?<![\w*_])(\*{1,3}|_{1,3})(?![*_])(.+?)\1(?![\w*_])/).each do
              match = Regexp.last_match
              content = text[match.begin(2)...match.end(2)]
              next if match.begin(0) < column || content.strip.empty? || content == content.strip

              range = document.range(number, match.begin(0), number, match.end(0))
              replacement = "#{match[1]}#{text[match.begin(2)...match.end(2)].strip}#{match[1]}"
              prose_offense(range, message: 'Remove spaces inside emphasis delimiters.') do |corrector|
                corrector.replace(processed_range(range), replacement)
              end
            end
          end
        end
      end
    end
  end
end
