# frozen_string_literal: true

module RuboCop
  module Cop
    module Markdown
      class EmphasisHeading < Base
        def investigate_paragraph(paragraph)
          children = paragraph.children.reject { |child| child.type == :text && child.value.strip.empty? }
          return unless children.one? && %i[em strong].include?(children.first.type)
          return unless document.line_numbers(paragraph).size == 1

          number = paragraph.options.fetch(:location)
          prose_offense(document.line_range(number), message: 'Use a heading instead of an emphasis-only paragraph.')
        end
      end
    end
  end
end
