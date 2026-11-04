# frozen_string_literal: true

require_relative '../../prose/inline_rules'

module RuboCop
  module Cop
    module Markdown
      class OutsideSpacing < Base
        WORD_CHARACTER = /[\p{L}\p{M}\p{N}]/u
        AMBIGUOUS_SCRIPT = /[\p{Han}\p{Hiragana}\p{Katakana}\p{Hangul}\p{Thai}\p{Lao}\p{Khmer}\p{Myanmar}]/u

        def investigate_document
          candidates = code_spans + emphasis_spans
          candidates.each do |first, last, content_first, content_last|
            next unless adjacent_words?(first, content_first, content_last, last)

            range = ::Parser::Source::Range.new(document.buffer, first, last)
            prose_offense(range, message: 'Separate inline formatting from adjacent prose words.')
          end
        end

        private

        def code_spans
          multiline = RuboCop::Prose::InlineRules.multiline_atoms(document)
          RuboCop::Prose::InlineRules.lines(document).flat_map do |text, number, column|
            line_start = document.line_range(number).begin_pos
            RuboCop::Prose::InlineRules.spans(text).filter_map do |span|
              next unless span.kind == :code && span.begin_pos >= column

              first = line_start + span.begin_pos
              last = line_start + span.end_pos
              range = ::Parser::Source::Range.new(document.buffer, first, last)
              next if multiline.any? { |atom| atom.overlaps?(range) }
              next if protected_ranges(number, text, line_start).any? { |atom| atom.overlaps?(range) }

              [first, last, first + span.delimiter.length, last - span.delimiter.length]
            end
          end
        end

        def emphasis_spans
          %i[em strong].flat_map do |type|
            document.emphasis_ranges(type).filter_map do |opening, closing, _delimiter|
              next unless opening.line == closing.line

              first = opening.begin_pos
              last = closing.end_pos
              number = opening.line
              line_start = document.line_range(number).begin_pos
              next if protected_ranges(number, document.line(number), line_start)
                      .any? { |atom| atom.begin_pos < last && first < atom.end_pos }

              [first, last, opening.end_pos, closing.begin_pos]
            end
          end
        end

        def protected_ranges(number, text, line_start)
          @protected_ranges ||= {}
          @protected_ranges[number] ||= RuboCop::Prose::InlineRules.spans(text).filter_map do |span|
            next if span.kind == :code

            ::Parser::Source::Range.new(document.buffer, line_start + span.begin_pos, line_start + span.end_pos)
          end
        end

        def adjacent_words?(first, content_first, content_last, last)
          source = document.buffer.source
          left = [source[first - 1], source[content_first]]
          right = [source[content_last - 1], source[last]]
          [left, right].any? do |outside, inside|
            word_character?(outside) && word_character?(inside) &&
              !ambiguous_script?(outside) && !ambiguous_script?(inside)
          end
        end

        def word_character?(character)
          character&.match?(WORD_CHARACTER)
        end

        def ambiguous_script?(character)
          character&.match?(AMBIGUOUS_SCRIPT)
        end
      end
    end
  end
end
