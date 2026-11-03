# frozen_string_literal: true

require_relative '../../prose/heading_rules'

module RuboCop
  module Cop
    module Markdown
      class ClosedHeadingSpace < Prose::Base
        include RuboCop::Prose::HeadingRules

        def investigate_document
          heading_entries.each do |heading|
            opening = heading[:opening]
            next unless opening && !heading[:closing]

            # An escaped final hash is text, not an intended closing marker.
            ending = /(?<slashes>\\*)(?<hashes>#+)[ \t]*\z/.match(opening[:rest])
            next unless ending && ending[:slashes].length.even?

            prose_offense(heading_range(heading), message: 'Separate closing heading hashes from text with a space.')
          end
        end
      end
    end
  end
end
