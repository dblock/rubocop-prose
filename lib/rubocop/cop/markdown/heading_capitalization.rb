# frozen_string_literal: true

require_relative '../../prose/capitalization_rules'

module RuboCop
  module Cop
    module Markdown
      class HeadingCapitalization < Base
        extend AutoCorrector
        include RuboCop::Prose::CapitalizationRules

        MSG = 'Capitalize the first prose letter of the heading.'
        TITLE_MSG = 'Use title case: capitalize major words and lowercase internal minor words.'

        def investigate_document
          document.nodes(:header).each do |node|
            text = prose_text(node)
            title_case = cop_config['Style'] == 'title_case'
            number = node.options.fetch(:location)
            opening = heading_opening(number)
            literal_lowercase = opening&.literal && lowercase_opening?(opening)
            invalid = title_case ? invalid_title?(text) || literal_lowercase : lowercase_opening?(opening)
            invalid ||= !title_case && !opening && invalid_initial?(text)
            next unless invalid

            range = opening&.literal || identifier_source?(document.line(number)) ? nil : correction_range(text, number)
            replacement = capitalized_text(text, title_case)
            prose_offense(document.line_range(number), message: title_case ? TITLE_MSG : MSG) do |corrector|
              corrector.replace(processed_range(range), replacement) if range
            end
          end
        end

        def heading_opening(number)
          source = document.line(number)
          text = source.sub(/\A(?:[ \t]*>[ \t]?)*[ \t]*(?:[-+*]|\d+[.)])?[ \t]*/, '')
          text = text.sub(/\A\#{1,6}[ \t]+/, '').sub(/[ \t]+\#{1,}[ \t]*\z/, '')
          opening_word(text)
        end
      end
    end
  end
end
