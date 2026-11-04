# frozen_string_literal: true

require_relative '../../prose/link_rules'

module RuboCop
  module Cop
    module Markdown
      class ImagePathSeparators < Base
        extend AutoCorrector

        MSG = 'Use forward slashes in local image destinations.'

        private

        def investigate_document
          scanner = document.link_rules
          reported = Set.new
          scanner.links.each do |link|
            scanner.image_path_separators(link).each do |position, ambiguous|
              next unless reported.add?(position)

              range = scanner.range(position, position + 1)
              prose_offense(range) do |corrector|
                corrector.replace(processed_range(range), '/') unless ambiguous
              end
            end
          end
        end
      end
    end
  end
end
