# frozen_string_literal: true

require_relative '../../prose/list_rules'

module RuboCop
  module Cop
    module Markdown
      class UnorderedListMarker < Base
        extend AutoCorrector
        include RuboCop::Prose::ListRules

        private

        def investigate_document
          style = cop_config.fetch('EnforcedStyle', 'consistent')
          expected = { 'asterisk' => '*', 'plus' => '+', 'dash' => '-' }[style]
          changes = []
          list_groups do |list, marks, _parent|
            next unless list.type == :ul

            expected ||= marks.first[:marker]
            marks.each do |mark|
              next if mark[:marker] == expected

              changes << [mark, expected]
            end
          end
          candidates = changes.group_by { |mark, _target| mark[:line] }.transform_values do |entries|
            text = document.line(entries.first.first[:line]).dup
            entries.each { |mark, target| text[mark[:column]] = target }
            text
          end
          changes.each do |mark, target|
            range = document.range(mark[:line], mark[:column], mark[:line], mark[:column] + 1)
            prose_offense(range, message: "Use `#{target}` for unordered list markers.") do |corrector|
              next if candidates.fetch(mark[:line]).match?(/(?:\A|[> \t])([*-])(?:[ \t]*\1){2,}[ \t]*\z/)

              corrector.replace(processed_range(range), target)
            end
          end
        end
      end
    end
  end
end
