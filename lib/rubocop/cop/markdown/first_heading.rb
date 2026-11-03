# frozen_string_literal: true

require_relative '../../prose/heading_rules'

module RuboCop
  module Cop
    module Markdown
      class FirstHeading < Prose::Base
        include RuboCop::Prose::HeadingRules

        def investigate_document
          return if front_matter_title?

          first = document.lines.each_with_index.find do |text, index|
            !document.front_matter_line?(index + 1) && !text.strip.empty?
          end
          return unless first

          number = first.last + 1
          heading = heading_entries.first
          return if heading && heading[:line] == number && heading[:level] == cop_config.fetch('Level', 1)

          prose_offense(document.line_range(number),
                        message: 'Start the document with a heading at the configured level.')
        end

        private

        def front_matter_title?
          return false unless cop_config.fetch('FrontMatterTitle', true) && document.front_matter

          lines = document.front_matter.lines
          metadata = YAML.safe_load(lines[1...-1].join)
          return false unless metadata.is_a?(Hash)

          title = metadata[cop_config.fetch('TitleKey', 'title')]
          title.is_a?(String) && !title.strip.empty?
        rescue Psych::Exception
          false
        end
      end
    end
  end
end
