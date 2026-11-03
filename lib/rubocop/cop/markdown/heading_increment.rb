# frozen_string_literal: true

require_relative '../../prose/heading_rules'

module RuboCop
  module Cop
    module Markdown
      class HeadingIncrement < Base
        include RuboCop::Prose::HeadingRules

        def investigate_document
          previous = nil
          heading_entries.each do |heading|
            if previous && heading[:level] > previous + 1
              prose_offense(heading_range(heading), message: 'Increase heading levels by at most one.')
            end
            previous = heading[:level]
          end
        end
      end
    end
  end
end
