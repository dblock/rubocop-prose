# frozen_string_literal: true

require_relative '../../prose/link_rules'

module RuboCop
  module Cop
    module Markdown
      class LinkTextSpacing < Prose::Base
        extend AutoCorrector

        MSG = 'Remove whitespace at the edges of link text.'

        private

        def investigate_document
          scanner = RuboCop::Prose::LinkRules.new(document)
          scanner.links.each do |link|
            next if link.image || link.style == 'autolink' || !scanner.resolved?(link)
            next if link.label == link.label.strip

            original = scanner.label_range(link)
            if link.label.strip.empty?
              prose_offense(original)
              next
            end
            prose_offense(original) do |corrector|
              corrector.replace(processed_range(original), link.label.strip)
            end
          end
        end
      end
    end
  end
end
