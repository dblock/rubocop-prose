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
            title_case = cop_config['EnforcedStyle'] == 'title_case'
            next unless title_case ? invalid_title?(text) : invalid_initial?(text)

            number = node.options.fetch(:location)
            range = correction_range(text, number)
            replacement = capitalized_text(text, title_case)
            prose_offense(document.line_range(number), message: title_case ? TITLE_MSG : MSG) do |corrector|
              corrector.replace(processed_range(range), replacement) if range
            end
          end
        end
      end
    end
  end
end
