# frozen_string_literal: true

require_relative '../../prose/heading_rules'

module RuboCop
  module Cop
    module Prose
      class HeadingStructure < Base
        include RuboCop::Prose::HeadingRules

        def investigate_document
          expected = cop_config.fetch('Headings', []).map do |heading|
            match = /\A(\#{1,6}) (.*)\z/.match(heading)
            raise ArgumentError, 'Headings must contain ATX outline strings such as "# Title".' unless match

            [match[1].length, match[2]]
          end
          return if expected.empty?

          headings = heading_entries
          headings.each_with_index do |heading, index|
            next if expected[index] == [heading[:level], heading[:text]]

            prose_offense(heading_range(heading), message: 'Match the configured exact heading outline.')
          end
          return unless expected.length > headings.length

          prose_offense(heading_end_range, message: 'Add the missing headings from the configured exact outline.')
        end
      end
    end
  end
end
