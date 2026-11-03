# frozen_string_literal: true

require_relative '../../prose/heading_rules'

module RuboCop
  module Cop
    module Markdown
      class DuplicateHeadings < Prose::Base
        include RuboCop::Prose::HeadingRules

        def investigate_document
          seen = Set.new
          parents = []
          heading_entries.each do |heading|
            parents.pop while parents.any? && parents.last[:level] >= heading[:level]
            scope = cop_config.fetch('Scope', 'siblings') == 'siblings' ? parents.last&.fetch(:line) : nil
            key = [scope, heading[:text]]
            if seen.include?(key)
              prose_offense(heading_range(heading), message: 'Use unique heading text within the configured scope.')
            end
            seen.add(key)
            parents << heading
          end
        end
      end
    end
  end
end
