# frozen_string_literal: true

require_relative '../../prose/list_rules'
require_relative '../../prose/capitalization_rules'

module RuboCop
  module Cop
    module Markdown
      class ListItemCapitalization < Base
        extend AutoCorrector
        include RuboCop::Prose::ListRules
        include RuboCop::Prose::CapitalizationRules

        private

        def investigate_document
          list_groups do |_list, marks, _parent|
            expected = nil
            marks.each do |mark|
              if cop_config['EnforcedStyle'] == 'title_case'
                investigate_title(mark)
                next
              end

              initial = prose_initial(mark)
              next unless initial

              range, style = initial
              next if initial.last && expected.nil? && cop_config['EnforcedStyle'] == 'consistent'

              expected ||= cop_config['EnforcedStyle'] == 'initial_capital' ? 'uppercase' : style
              next if style == expected

              prose_offense(range, message: "Use #{expected} initial capitalization in list items.") do |corrector|
                next if initial.last

                replacement = expected == 'uppercase' ? range.source.upcase : range.source.downcase
                corrector.replace(processed_range(range), replacement)
              end
            end
          end
        end

        def investigate_title(mark)
          paragraph = mark[:item].children.first
          return unless paragraph&.type == :p && paragraph.options[:prose_source]
          return unless paragraph.options[:location] == mark[:line]

          source = paragraph.options[:prose_source]
          checkbox = source[/\A[ \t]*\[[ xX]\][ \t]+/].to_s
          text = prose_text(paragraph).sub(/\A\[[ xX]\][ \t]+/, '')
          opening = opening_word(source[checkbox.length..])
          return unless invalid_title?(text) || (opening&.literal && lowercase_opening?(opening))

          range = opening&.literal || identifier_source?(source) ? nil : correction_range(text, mark[:line])
          prose_offense(document.line_range(mark[:line]), message: 'Use title case in list items.') do |corrector|
            corrector.replace(processed_range(range), capitalized_text(text, true)) if range
          end
        end

        def prose_initial(mark)
          paragraph = mark[:item].children.first
          return unless paragraph&.type == :p && paragraph.options[:prose_source]
          return unless paragraph.options[:location] == mark[:line]

          source = paragraph.options[:prose_source]
          checkbox = source[/\A[ \t]*\[[ xX]\][ \t]+/].to_s
          text = source[checkbox.length..]
          opening = opening_word(text)
          word = opening&.word
          return unless word&.match?(/\A[\p{L}\p{M}]+\z/) ||
                        (opening&.code && word&.match?(/\A[\p{L}\p{M}][\p{L}\p{M}\p{N}_]*\z/))

          return if ignored_word?(opening.word)
          return if cop_config['PreserveMixedCase'] && opening.word[1..].match?(/[\p{Lu}\p{Lt}]/)

          after = text[opening.end_pos..].sub(/\A(?:\*+|_+|`+|["'“”‘’»›\]]+)+/, '')
          return if after.match?(%r{\A(?:[\p{L}\p{M}_]|[._/:-])})

          offset = checkbox.length + opening.begin_pos
          return if source[0...offset].include?("\n")

          column = document.content_start(paragraph, mark[:line]) + offset
          range = document.range(mark[:line], column, mark[:line], column + 1)
          [range, opening.word[0].match?(/\p{Ll}/) ? 'lowercase' : 'uppercase', opening.literal]
        end
      end
    end
  end
end
