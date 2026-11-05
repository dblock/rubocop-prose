# frozen_string_literal: true

module RuboCop
  module Cop
    module Text
      class HardTabs < Base
        private

        def investigate_document
          document.lines.each_with_index do |text, index|
            text.to_enum(:scan, /\t/).each do
              position = Regexp.last_match.begin(0)
              prose_offense(document.range(index + 1, position, index + 1, position + 1),
                            message: 'Use spaces instead of hard tabs.')
            end
          end
        end
      end
    end
  end
end
