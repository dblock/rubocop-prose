# frozen_string_literal: true

module RuboCop
  module Cop
    module Text
      class TrailingWhitespace < Prose::Base
        extend AutoCorrector

        private

        def investigate_document
          document.lines.each_with_index do |text, index|
            match = text.match(/[ \t]+\z/)
            next unless match

            range = document.range(index + 1, match.begin(0))
            prose_offense(range, message: 'Remove trailing whitespace.') do |corrector|
              corrector.remove(processed_range(range))
            end
          end
        end
      end
    end
  end
end
