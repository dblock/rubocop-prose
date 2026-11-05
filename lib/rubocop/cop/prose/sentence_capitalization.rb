# frozen_string_literal: true

require_relative '../../prose/capitalization_rules'

module RuboCop
  module Cop
    module Prose
      class SentenceCapitalization < Base
        extend AutoCorrector
        include RuboCop::Prose::CapitalizationRules

        MSG = 'Capitalize or rephrase this lowercase paragraph opening without changing its literal text.'

        def investigate_document
          if document.is_a?(RuboCop::Prose::MarkdownDocument)
            investigate_markdown
          else
            investigate_text
          end
        end

        private

        def investigate_markdown
          list_openings = list_opening_paragraphs
          table_paragraphs = paragraphs_in_tables
          (document.paragraphs + footnote_paragraphs).uniq(&:object_id).each do |paragraph|
            next if list_openings.include?(paragraph.object_id) || table_paragraphs.include?(paragraph.object_id)

            source = paragraph.options[:prose_source]
            opening = opening_word(source)
            next if opening && !opening.literal && ambiguous_identifier_opening?(source, opening)

            number = paragraph.options[:location]
            investigate_opening(source, number, opening, document.content_start(paragraph, number))
          end
        end

        def investigate_text
          document.paragraphs.each do |paragraph|
            number = paragraph.first_line
            source = document.line(number)
            opening = opening_word(source, markdown: false)
            next if opening && !opening.literal && ambiguous_identifier_opening?(source, opening)

            investigate_opening(source, number, opening)
          end
        end

        def investigate_opening(source, number, opening, column_offset = 0)
          return unless lowercase_opening?(opening)
          return if source[0...opening.begin_pos].include?("\n")

          column = column_offset + opening.begin_pos
          range = document.range(number, column, number, column + 1)
          prose_offense(range, message: MSG) do |corrector|
            next if opening.literal

            corrector.replace(processed_range(range), range.source.upcase)
          end
        end

        def list_opening_paragraphs
          openings = []
          visit = lambda do |node|
            if node.type == :li
              first = node.children.first
              openings << first.object_id if first&.type == :p && first.options[:prose_source]
            end
            node.children.each { |child| visit.call(child) }
          end
          visit.call(document.root)
          openings
        end

        def paragraphs_in_tables
          paragraphs = []
          visit = lambda do |node|
            paragraphs << node.object_id if node.type == :p && node.options[:prose_source]
            node.children.each { |child| visit.call(child) }
          end
          document.nodes(:table).each { |table| visit.call(table) }
          paragraphs
        end

        def footnote_paragraphs
          paragraphs = []
          visit = lambda do |node|
            paragraphs << node if node.type == :p && node.options[:prose_source]
            node.children.each { |child| visit.call(child) }
          end
          document.nodes(:footnote).each do |footnote|
            visit.call(footnote.value) if footnote.value.respond_to?(:children)
          end
          paragraphs
        end
      end
    end
  end
end
