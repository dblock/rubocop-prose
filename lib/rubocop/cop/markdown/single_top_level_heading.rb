# frozen_string_literal: true

require_relative '../../prose/heading_rules'

module RuboCop
  module Cop
    module Markdown
      class SingleTopLevelHeading < Prose::Base
        include RuboCop::Prose::HeadingRules

        def investigate_document
          heading_entries.select { |heading| heading[:level] == cop_config.fetch('Level', 1) }.drop(1).each do |heading|
            prose_offense(heading_range(heading), message: 'Use at most one top-level heading.')
          end
        end
      end
    end
  end
end
