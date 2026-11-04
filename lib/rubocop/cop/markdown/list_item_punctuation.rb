# frozen_string_literal: true

require_relative '../../prose/list_rules'

module RuboCop
  module Cop
    module Markdown
      class ListItemPunctuation < Base
        include RuboCop::Prose::ListRules

        TERMINAL_PUNCTUATION = /[.!?…]+\z/
        CLOSING_QUOTES = /["'’”»›]+\z/

        private

        def investigate_document
          list_groups do |list, marks, _parent|
            next unless marks.length == list.children.count { |child| child.type == :li }

            items = marks.map { |mark| [mark, terminal_punctuation(mark[:item])] }
            next if items.any? { |_mark, punctuation| punctuation.nil? }

            style = cop_config.fetch('EnforcedStyle', 'consistent')
            expected = style == 'consistent' ? items.first.last != false : style == 'always'
            items.each do |mark, punctuation|
              message = item_message(style, punctuation, expected)
              next unless message

              prose_offense(document.range(mark[:line], mark[:column], mark[:line],
                                           mark[:column] + mark[:marker].length),
                            message: message)
            end
          end
        end

        def item_message(style, punctuation, expected)
          return punctuation_message(style) if (punctuation != false) != expected
          return unless punctuation
          return if punctuation.each_char.all? { |char| cop_config['AllowedPunctuation'].include?(char) }

          'Use only configured terminal punctuation.'
        end

        def punctuation_message(style)
          case style
          when 'always' then 'End list items with terminal punctuation.'
          when 'never' then 'Do not end list items with terminal punctuation.'
          else 'Use terminal punctuation consistently with sibling list items.'
          end
        end

        def terminal_punctuation(item)
          return unless item.children.one? && item.children.first.type == :p

          paragraph = item.children.first
          return unless paragraph.options[:prose_source]

          text = document.plain_text(paragraph).rstrip.sub(CLOSING_QUOTES, '')
          text[TERMINAL_PUNCTUATION] || false
        end
      end
    end
  end
end
