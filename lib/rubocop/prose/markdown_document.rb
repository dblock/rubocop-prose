# frozen_string_literal: true

require_relative 'table_rules'

module RuboCop
  module Prose
    class MarkdownDocument < Document
      FRONT_MATTER = /\A(?:\uFEFF)?---[ \t]*\r?\n.*?^(?:---|\.\.\.)[ \t]*(?:\r?\n|\z)/m
      BLOCK_START = /\A(?:[>#]|[-+*](?:\s|\z)|\d+[.)](?:\s|\z)|`{3}|~{3}|[=-]+[\t ]*\z)/

      attr_reader :front_matter

      def self.file?(path, configuration = nil)
        Document.format(path, configuration) == :markdown
      end

      def initialize(buffer, ignore_front_matter: true, configuration: {})
        ignore_front_matter = configuration.fetch('Markdown', {}).fetch('IgnoreFrontMatter', ignore_front_matter)
        unless [true, false].include?(ignore_front_matter)
          raise ValidationError, 'Markdown: IgnoreFrontMatter must be true or false.'
        end

        super(buffer)
        @front_matter = source[FRONT_MATTER]
        @front_matter_lines = @front_matter&.lines&.length
        @ignore_front_matter = ignore_front_matter
      end

      def root
        parsed.first
      end

      def warnings
        parsed.last
      end

      def nodes(type)
        @nodes ||= walk(root).group_by(&:type)
        @nodes.fetch(type, [])
      end

      def paragraphs
        @paragraphs ||= nodes(:p).select { |node| node.options[:prose_source] }
      end

      def hard_breaks
        @hard_breaks ||= paragraphs.flat_map { |paragraph| find_hard_breaks(paragraph) }
      end

      def link_rules
        @link_rules ||= LinkRules.new(self)
      end

      def tables
        @tables ||= TableRules.tables(self)
      end

      def inline_lines
        @inline_lines ||= InlineRules.lines(self)
      end

      def inline_spans(number)
        @inline_spans ||= {}
        @inline_spans[number] ||= InlineRules.spans(line(number))
      end

      def emphasis_ranges(type)
        @emphasis_ranges ||= InlineRules.emphasis(self)
        @emphasis_ranges.fetch(type, [])
      end

      def multiline_atoms
        @multiline_atoms ||= paragraphs.flat_map { |paragraph| atomic_ranges(paragraph) }
                                       .reject { |range| range.line == range.last_line }
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
        @ignore_front_matter && @front_matter_lines && number <= @front_matter_lines
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
          atoms = paragraph.options[:prose_atoms]
          unless atoms.empty?
            inline = ::Parser::Source::Buffer.new('(paragraph)', source: paragraph.options[:prose_source])
          end
          atoms.map do |first, last|
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
        paragraph.options[:prose_lines] ||= paragraph.options[:prose_source].split("\n", -1)
      end

      def parsed
        @parsed ||= begin
          text = @ignore_front_matter ? source.sub(FRONT_MATTER) { |header| header.gsub(/[^\r\n]/, ' ') } : source
          Parser.parse(text, hard_wrap: false, gfm_quirks: %i[paragraph_end no_auto_typographic])
        end
      end

      def walk(node, found = [])
        found << node
        node.children.each { |child| walk(child, found) }
        found
      end

      def find_hard_breaks(node, found = [])
        node.children.each do |child|
          child.type == :br ? found << child : find_hard_breaks(child, found)
        end
        found
      end
    end
  end
end
