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
          hard_break_lines = document.hard_breaks.to_set { |node| node.options[:location] }
          document.lines.each_with_index do |text, index|
            number = index + 1
            next if document.front_matter_line?(number)
            next if document.code_line?(number) && !cop_config['CodeBlocks']

            match = text.match(/[ \t]+\z/)
            next unless match
            next if allowed_empty_blockquote_space?(text, number, match[0])

            spaces = text[/ +\z/].to_s.length
            hard_break = !text.strip.empty? && paragraphs.include?(number) && spaces >= 2
            style = hard_break_style
            handled_by_style = hard_break_lines.include?(number) && hard_break &&
                               style && (style['Style'] == 'backslash' || text[0...-spaces].end_with?('\\'))
            next if handled_by_style

            keep = hard_break ? ' ' * cop_config['HardBreakSpaces'] : ''
            next if match[0] == keep

            range = document.range(number, match.begin(0))
            prose_offense(range) do |corrector|
              corrector.replace(processed_range(range), keep) unless document.code_line?(number)
            end
          end
        end

        def hard_break_style
          style = config.for_cop('Markdown/HardBreakStyle')
          style if style && style['Enabled']
        end

        def allowed_empty_blockquote_space?(text, number, whitespace)
          cop_config['AllowEmptyBlockquoteSpace'] && whitespace == ' ' &&
            !document.code_line?(number) && text.match?(/\A[ \t]*>(?:[ \t]*>)* \z/)
        end
      end
    end
  end
end
