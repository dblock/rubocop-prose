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

        INITIAL_WORD = /\A[ \t]*(?:\[[ xX]\][ \t]+)?(?<word>\p{L}[\p{L}\p{M}]*)(?=\s|[.,!?:;](?:\s|\z)|\z)/

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
              expected ||= cop_config['EnforcedStyle'] == 'initial_capital' ? 'uppercase' : style
              next if style == expected

              prose_offense(range, message: "Use #{expected} initial capitalization in list items.") do |corrector|
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

          text = prose_text(paragraph).sub(/\A\[[ xX]\][ \t]+/, '')
          return unless invalid_title?(text)

          range = correction_range(text, mark[:line])
          prose_offense(document.line_range(mark[:line]), message: 'Use title case in list items.') do |corrector|
            corrector.replace(processed_range(range), capitalized_text(text, true)) if range
          end
        end

        def prose_initial(mark)
          paragraph = mark[:item].children.first
          return unless paragraph&.type == :p && paragraph.options[:prose_source]
          return unless paragraph.options[:location] == mark[:line]

          text = initial_text(paragraph)
          return unless text

          match = INITIAL_WORD.match(text)
          return unless match

          word = match[:word]
          return unless INITIAL_WORD.match(document.plain_text(paragraph))&.[](:word) == word
          return if ignored_word?(word)
          return unless word.match?(/[\p{Ll}\p{Lu}\p{Lt}]/)
          return if cop_config['PreserveMixedCase'] && word[1..].match?(/[\p{Lu}\p{Lt}]/)

          source = paragraph.options[:prose_source]
          offset = source.index(text)
          return unless offset

          offset += match.begin(:word)
          return if source[0...offset].include?("\n")

          column = document.content_start(paragraph, mark[:line]) + offset
          range = document.range(mark[:line], column, mark[:line], column + 1)
          [range, word[0].match?(/\p{Ll}/) ? 'lowercase' : 'uppercase']
        end

        def initial_text(node)
          child = node.children.first
          if node.type == :p && child&.type == :text && child.value.match?(/\A\[[ xX]\][ \t]+\z/)
            child = node.children[1]
          end
          return unless child
          return child.value if child.type == :text

          initial_text(child) if %i[em strong a].include?(child.type)
        end
      end
    end
  end
end
