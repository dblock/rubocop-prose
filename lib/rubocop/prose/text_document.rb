# frozen_string_literal: true

module RuboCop
  module Prose
    class TextDocument < Document
      Paragraph = Struct.new(:first_line, :last_line)

      def self.file?(path)
        path && File.extname(path).casecmp?('.txt')
      end

      def paragraphs
        @paragraphs ||= begin
          result = []
          lines.each_with_index do |text, index|
            next if text.strip.empty?

            number = index + 1
            if result.last && result.last.last_line == number - 1
              result.last.last_line = number
            else
              result << Paragraph.new(number, number)
            end
          end
          result
        end
      end

      def line_numbers(paragraph)
        paragraph.first_line..paragraph.last_line
      end

      def content_start(_paragraph, _number)
        0
      end

      def continuation_prefix(_paragraph)
        ''
      end

      def atomic_ranges(_paragraph)
        []
      end

      def soft_breaks(paragraph)
        (paragraph.first_line...paragraph.last_line).to_a
      end

      def reflowable?(paragraph)
        line_numbers(paragraph).none? { |number| line(number).match?(/\A[ \t]/) }
      end
    end
  end
end
