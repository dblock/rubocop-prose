# frozen_string_literal: true

module RuboCop
  module Prose
    class Document
      attr_reader :buffer, :lines

      def self.format(path, configuration = nil)
        (configuration ? configuration.prose_file_types : FileTypes.default).format(path)
      end

      def self.file?(path, configuration = nil)
        !format(path, configuration).nil?
      end

      def self.build(path, buffer, configuration: nil, format: self.format(path, configuration))
        case format
        when :markdown then MarkdownDocument.new(buffer, configuration: configuration || {})
        when :text then TextDocument.new(buffer)
        else raise ArgumentError, "Unsupported prose document: #{path.inspect}"
        end
      end

      def initialize(buffer)
        @buffer = buffer
        @lines = source.lines(chomp: true)
      end

      def source
        buffer.source
      end

      def line(number)
        lines.fetch(number - 1)
      end

      def range(first_line, first_column = 0, last_line = first_line, last_column = nil)
        last_column ||= line(last_line).length
        ::Parser::Source::Range.new(
          buffer, buffer.line_range(first_line).begin_pos + first_column,
          buffer.line_range(last_line).begin_pos + last_column
        )
      end

      def line_range(number)
        range(number)
      end

      def ignored_line?(_number)
        false
      end

      def reflowable?(_paragraph)
        true
      end

      def breakable_space?(_text, _first, _last)
        true
      end
    end
  end
end
