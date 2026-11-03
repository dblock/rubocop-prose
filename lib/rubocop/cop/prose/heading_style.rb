# frozen_string_literal: true

require_relative '../../prose/heading_rules'

module RuboCop
  module Cop
    module Prose
      class HeadingStyle < Base
        include RuboCop::Prose::HeadingRules

        def investigate_document
          headings = heading_entries
          style = cop_config.fetch('EnforcedStyle', 'consistent')
          style = headings.first&.fetch(:style) if style == 'consistent'
          headings.each do |heading|
            next if heading[:style] == style

            prose_offense(heading_range(heading), message: "Use #{style} headings.")
          end
        end
      end
    end
  end
end
