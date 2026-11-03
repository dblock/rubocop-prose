# frozen_string_literal: true

require_relative '../../prose/inline_rules'

module RuboCop
  module Cop
    module Markdown
      class CodeSpanSpacing < Base
        extend AutoCorrector

        def investigate_document
          multiline = RuboCop::Prose::InlineRules.multiline_atoms(document)
                                                 .select { |range| range.source.start_with?('`') }
          RuboCop::Prose::InlineRules.lines(document).each do |text, number, column|
            RuboCop::Prose::InlineRules.spans(text).each do |span|
              next unless span.kind == :code && span.begin_pos >= column

              position = document.range(number, span.begin_pos, number, span.end_pos)
              next if multiline.any? { |range| range.overlaps?(position) }

              width = span.delimiter.length
              content = text[(span.begin_pos + width)...(span.end_pos - width)]
              next if content.strip.empty? || content == content.strip
              # One space on each side is the Markdown escape for literal edge backticks.
              next if content.start_with?(' ') && content.end_with?(' ') &&
                      (content[1] == '`' || content[-2] == '`')

              range = document.range(number, span.begin_pos, number, span.end_pos)
              prose_offense(range, message: 'Avoid unnecessary padding inside code spans.') do |corrector|
                # Only symmetric single-space padding can be removed without changing the value.
                next unless content.start_with?(' ') && content.end_with?(' ')
                next if content[1] == ' ' || content[-2] == ' '

                corrector.replace(processed_range(range), "#{span.delimiter}#{content[1...-1]}#{span.delimiter}")
              end
            end
            multiline.each do |range|
              delimiter = range.source[/\A`+/]
              content = range.source[delimiter.length...-delimiter.length]
              next if content.strip.empty? || content == content.strip
              next if content.start_with?(' ') && content.end_with?(' ') &&
                      (content[1] == '`' || content[-2] == '`')

              prose_offense(range, message: 'Avoid unnecessary padding inside code spans.')
            end
          end
        end
      end
    end
  end
end
