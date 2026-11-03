# frozen_string_literal: true

module RuboCop
  module Prose
    class MarkdownDocument < Document
      EXTENSIONS = %w[.md .markdown .mdown .mdwn .mkd .mkdn .mkdown .livemd .ronn .scd .workbook].freeze
      FRONT_MATTER = /\A(?:\uFEFF)?---[ \t]*\r?\n.*?^(?:---|\.\.\.)[ \t]*(?:\r?\n|\z)/m
      BLOCK_START = /\A(?:[>#]|[-+*](?:\s|\z)|\d+[.)](?:\s|\z)|`{3}|~{3}|[=-]+[\t ]*\z)/

      attr_reader :front_matter

      def self.file?(path)
        path && EXTENSIONS.include?(File.extname(path).downcase)
      end

      def initialize(buffer, ignore_front_matter: true)
        super(buffer)
        @front_matter = source[FRONT_MATTER]
        @ignore_front_matter = ignore_front_matter
      end

      def root
        parsed.first
      end

      def warnings
        parsed.last
      end

      def nodes(type)
        walk(root).select { |node| node.type == type }
      end

      def paragraphs
        nodes(:p).select { |node| node.options[:prose_source] }
      end

      def headings
        nodes(:header).map { |node| [node.options[:level], plain_text(node), node.options[:location]] }
      end

      def plain_text(node)
        return node.value.to_s if %i[text codespan].include?(node.type)
        return node.value.char if node.type == :entity

        node.children.map { |child| plain_text(child) }.join
      end

      def front_matter_line?(number)
        @ignore_front_matter && front_matter && number <= front_matter.lines.length
      end

      def code_line?(number)
        @code_lines ||= nodes(:codeblock).flat_map do |node|
          first = node.options.fetch(:location)
          length = node.value.lines.length + (node.options[:fenced] ? 2 : 0)
          (first...(first + length)).to_a
        end.to_set
        @code_lines.include?(number)
      end

      def ignored_line?(number)
        code_line?(number) || front_matter_line?(number)
      end

      def breakable_space?(text, first, last)
        !text[last..].match?(BLOCK_START) && text[0...first][/\\+\z/].to_s.length.even?
      end

      def prose_lines
        return enum_for(__method__) unless block_given?

        lines.each_with_index do |text, index|
          number = index + 1
          yield text, number unless code_line?(number) || front_matter_line?(number)
        end
      end

      def content_start(paragraph, number)
        text = source_lines(paragraph).fetch(number - paragraph.options[:location])
        line(number).rindex(text) || raise("Cannot map Markdown paragraph on line #{number}")
      end

      def line_numbers(paragraph)
        first = paragraph.options[:location]
        first...(first + source_lines(paragraph).length)
      end

      def continuation_prefix(paragraph)
        number = paragraph.options[:location]
        prefix = line(number)[0...content_start(paragraph, number)]
        prefix.gsub(/[-+*]|\d+[.)]/) { |marker| ' ' * marker.length }
      end

      def soft_breaks(paragraph)
        line_numbers(paragraph).to_a[0...-1].reject do |number|
          text = line(number)
          join = range(number, text.rstrip.length, number + 1, content_start(paragraph, number + 1))
          following = line(number + 1)[content_start(paragraph, number + 1)..]
          text.end_with?('  ') || text[/\\+\z/].to_s.length.odd? ||
            text.match?(/<br\b[^>]*>\s*\z/i) || following.match?(/\A<br\b[^>]*>/i) ||
            atomic_ranges(paragraph).any? { |atom| atom.overlaps?(join) }
        end
      end

      def atomic_ranges(paragraph)
        paragraph.options[:original_ranges] ||= begin
          inline = ::Parser::Source::Buffer.new('(paragraph)', source: paragraph.options[:prose_source])
          paragraph.options[:prose_atoms].map do |first, last|
            start_line, start_column = inline.decompose_position(first)
            end_line, end_column = inline.decompose_position(last)
            first_line = paragraph.options[:location] + start_line - 1
            last_line = paragraph.options[:location] + end_line - 1
            range(first_line, content_start(paragraph, first_line) + start_column,
                  last_line, content_start(paragraph, last_line) + end_column)
          end
        end
      end

      private

      def source_lines(paragraph)
        paragraph.options[:prose_source].split("\n", -1)
      end

      def parsed
        @parsed ||= begin
          text = @ignore_front_matter ? source.sub(FRONT_MATTER) { |header| header.gsub(/[^\r\n]/, ' ') } : source
          Parser.parse(text, hard_wrap: false, gfm_quirks: %i[paragraph_end no_auto_typographic])
        end
      end

      def walk(node)
        [node] + node.children.flat_map { |child| walk(child) }
      end
    end
  end
end
