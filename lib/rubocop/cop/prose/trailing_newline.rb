# frozen_string_literal: true

module RuboCop
  module Cop
    module Prose
      class TrailingNewline < Base
        extend AutoCorrector

        private

        def investigate_document
          source = document.source
          return if source.empty?

          suffix = source.match(/\n*\z/)
          return if suffix[0] == "\n"

          range = ::Parser::Source::Range.new(document.buffer, suffix.begin(0), source.length)
          prose_offense(range, message: 'End the document with exactly one newline.') do |corrector|
            corrector.replace(processed_range(range), "\n")
          end
        end
      end
    end
  end
end
