# frozen_string_literal: true

module RuboCop
  module Cop
    module Markdown
      class HardBreakStyle < Base
        extend AutoCorrector

        MSG = 'Use the configured Markdown hard-break style.'
        STYLES = %w[backslash spaces].freeze

        def validate_config
          style = cop_config['Style']
          return if STYLES.include?(style)

          raise ValidationError, 'Markdown/HardBreakStyle: Style must be backslash or spaces.'
        end

        private

        def investigate_document
          document.hard_breaks.each { |node| investigate_break(node) }
        end

        def investigate_break(node)
          number = node.options[:location]
          text = document.line(number)
          marker = marker_for(text)
          return unless marker

          style, first_column, last_column = marker
          return if style.to_s == cop_config.fetch('Style', 'backslash')

          range = document.range(number, first_column, number, last_column)
          prose_offense(range) do |corrector|
            next unless safe_to_correct?(style, text, first_column)

            replacement = cop_config['Style'] == 'backslash' ? '\\' : '  '
            correction_range = if style == :backslash
                                 document.range(number, last_column - 1, number, last_column)
                               else
                                 range
                               end
            corrector.replace(processed_range(correction_range), replacement)
          end
        end

        def marker_for(text)
          if (spaces = / {2,}\z/.match(text))
            [:spaces, spaces.begin(0), spaces.end(0)]
          elsif (slashes = /\\+\z/.match(text))
            [:backslash, slashes.begin(0), slashes.end(0)]
          end
        end

        def safe_to_correct?(style, text, first_column)
          return false unless processed_source.raw_source == processed_source.buffer.source
          return true if style == :backslash

          !text[...first_column].end_with?('\\')
        end
      end
    end
  end
end
