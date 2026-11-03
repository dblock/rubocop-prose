# frozen_string_literal: true

module RuboCop
  module Cop
    module Prose
      class ThematicBreakStyle < Base
        extend AutoCorrector

        def investigate_document
          expected = cop_config.fetch('Style', 'consistent')
          return unless expected == 'consistent' ||
                        expected.match?(/\A(?:(?:\*[ \t]*){3,}|(?:-[ \t]*){3,}|(?:_[ \t]*){3,})\z/)

          document.nodes(:hr).each do |node|
            number = node.options[:location]
            next if document.front_matter_line?(number)

            text = document.line(number)
            match = /(?:\*[ \t]*){3,}|(?:-[ \t]*){3,}|(?:_[ \t]*){3,}/.match(text)
            next unless match

            actual = match[0].rstrip
            expected = actual if expected == 'consistent'
            next if actual == expected

            range = document.range(number, match.begin(0), number, match.begin(0) + actual.length)
            prose_offense(range, message: "Use `#{expected}` for thematic breaks.") do |corrector|
              corrector.replace(processed_range(range), expected)
            end
          end
        end
      end
    end
  end
end
