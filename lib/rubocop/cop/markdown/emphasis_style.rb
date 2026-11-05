# frozen_string_literal: true

require_relative '../../prose/inline_rules'

module RuboCop
  module Cop
    module Markdown
      class EmphasisStyle < Base
        extend AutoCorrector

        def validate_config
          styles = cop_config['SupportedStyles']
          return if styles.include?(cop_config['Style'])

          raise ValidationError, "#{cop_name}: Style must be one of #{styles.join(', ')}."
        end

        def investigate_document
          expected = cop_config.fetch('Style', 'consistent')
          document.emphasis_ranges(:em).each do |opening, closing, char|
            actual = char == '*' ? 'asterisk' : 'underscore'
            expected = actual if expected == 'consistent'
            next if actual == expected

            replacement = expected == 'asterisk' ? '*' : '_'
            # Underscores cannot delimit intraword emphasis.
            before = opening.begin_pos.positive? ? document.source[opening.begin_pos - 1] : nil
            after = document.source[closing.end_pos]

            prose_offense(opening, message: "Use #{expected} emphasis.") do |corrector|
              next if replacement == '_' && (before&.match?(/[[:alnum:]_]/) || after&.match?(/[[:alnum:]_]/))

              corrector.replace(processed_range(opening), replacement)
              corrector.replace(processed_range(closing), replacement)
            end
          end
        end
      end
    end
  end
end
