# frozen_string_literal: true

module RuboCop
  module Cop
    module Markdown
      class TrailingWhitespace < Base
        extend AutoCorrector

        MSG = 'Remove unexpected trailing whitespace; preserve Markdown hard breaks.'

        def validate_config
          value = cop_config['HardBreakSpaces']
          return if value.is_a?(Integer) && value >= 2

          raise ValidationError, 'Markdown/TrailingWhitespace: HardBreakSpaces must be an integer of at least two.'
        end

        private

        def investigate_document
          paragraphs = document.paragraphs.flat_map { |paragraph| document.line_numbers(paragraph).to_a }.to_set
          document.lines.each_with_index do |text, index|
            number = index + 1
            next if document.front_matter_line?(number)
            next if document.code_line?(number) && !cop_config['CodeBlocks']

            match = text.match(/[ \t]+\z/)
            next unless match

            spaces = text[/ +\z/].to_s.length
            hard_break = !text.strip.empty? && paragraphs.include?(number) && spaces >= 2
            keep = hard_break ? ' ' * cop_config['HardBreakSpaces'] : ''
            next if match[0] == keep

            range = document.range(number, match.begin(0))
            prose_offense(range) do |corrector|
              corrector.replace(processed_range(range), keep) unless document.code_line?(number)
            end
          end
        end
      end
    end
  end
end
