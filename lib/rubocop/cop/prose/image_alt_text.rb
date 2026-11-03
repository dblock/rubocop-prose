# frozen_string_literal: true

require_relative '../../prose/link_rules'

module RuboCop
  module Cop
    module Prose
      class ImageAltText < Base
        MSG = 'Provide alternative text for the image.'

        private

        def investigate_document
          scanner = RuboCop::Prose::LinkRules.new(document)
          scanner.links.each do |link|
            next unless link.image && scanner.resolved?(link) && scanner.display_text(link).empty?

            prose_offense(scanner.link_range(link))
          end
        end
      end
    end
  end
end
