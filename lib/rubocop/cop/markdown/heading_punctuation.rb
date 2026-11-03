# frozen_string_literal: true

require_relative '../../prose/heading_rules'

module RuboCop
  module Cop
    module Markdown
      class HeadingPunctuation < Base
        include RuboCop::Prose::HeadingRules

        def investigate_document
          punctuation = cop_config.fetch('Punctuation', '.,;:!?')
          heading_entries.each do |heading|
            ending = heading[:text].rstrip[-1]
            next unless ending && punctuation.include?(ending)

            prose_offense(heading_range(heading), message: 'Do not end headings with configured punctuation.')
          end
        end
      end
    end
  end
end
