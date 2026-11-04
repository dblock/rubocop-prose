# frozen_string_literal: true

module RuboCop
  module Cop
    module Markdown
      class ThematicBreakStyle < Base
        extend AutoCorrector

        def investigate_document
          style = cop_config.fetch('Style', 'consistent')
          styles = configured_styles(style)
          consistent = style == 'consistent'
          expected = nil

          document.nodes(:hr).each do |node|
            number = node.options[:location]
            next if document.front_matter_line?(number)

            text = document.line(number)
            match = /(?:\*[ \t]*){3,}|(?:-[ \t]*){3,}|(?:_[ \t]*){3,}/.match(text)
            next unless match

            actual = match[0].rstrip
            expected ||= actual if consistent
            next if consistent ? actual == expected : styles.include?(actual)

            range = document.range(number, match.begin(0), number, match.begin(0) + actual.length)
            replacement = if consistent
                            expected
                          elsif styles.one?
                            styles.first
                          end
            message = if consistent || styles.one?
                        "Use `#{replacement}` for thematic breaks."
                      else
                        "Use one of #{styles.map { |value| "`#{value}`" }.join(' or ')} for thematic breaks."
                      end
            if replacement
              prose_offense(range, message: message) do |corrector|
                corrector.replace(processed_range(range), replacement)
              end
            else
              prose_offense(range, message: message)
            end
          end
        end

        private

        def configured_styles(style)
          return [] if style == 'consistent'

          styles = style.is_a?(Array) ? style : [style]
          valid = !styles.empty? && styles.all? do |value|
            value.is_a?(String) && thematic_break?(value)
          end
          unless valid
            raise ValidationError, [
              'Markdown/ThematicBreakStyle: Style must be `consistent`,',
              'a literal break, or a nonempty array of valid breaks.'
            ].join(' ')
          end

          styles.uniq
        end

        def thematic_break?(value)
          match = /\A(?:(?:\*[ \t]*){3,}|(?:-[ \t]*){3,}|(?:_[ \t]*){3,})\z/.match(value)
          match && match[0].rstrip == value
        end
      end
    end
  end
end
