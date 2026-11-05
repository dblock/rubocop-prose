# frozen_string_literal: true

require_relative '../../prose/heading_rules'

module RuboCop
  module Cop
    module Markdown
      class FirstHeading < Base
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

        def validate_config
          title_key = cop_config['FrontMatterTitle']
          return if title_key == false || (title_key.is_a?(String) && !title_key.strip.empty?)

          raise ValidationError,
                "#{cop_name}: FrontMatterTitle must be a nonempty metadata key or false; " \
                'replace `FrontMatterTitle: true` and `TitleKey` with the metadata key, or use false to disable.'
        end

        private

        def front_matter_title?
          title_key = cop_config['FrontMatterTitle']
          return false if title_key == false
          return false unless document.front_matter

          lines = document.front_matter.lines
          metadata = YAML.safe_load(lines[1...-1].join)
          return false unless metadata.is_a?(Hash)

          title = metadata[title_key]
          title.is_a?(String) && !title.strip.empty?
        rescue Psych::Exception
          false
        end
      end
    end
  end
end
