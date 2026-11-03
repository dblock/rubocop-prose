# frozen_string_literal: true

require 'kramdown'
require 'kramdown-parser-gfm'

module RuboCop
  module Prose
    class Parser < Kramdown::Parser::GFM
      protected

      def parse_codeblock_fenced
        result = super
        if result
          block = @tree.children.last
          block.options[:fenced] = true
          block.options[:code_start_line] = block.options[:location] + 1
        end
        result
      end

      def parse_codeblock
        result = super
        @tree.children.last.options[:code_start_line] = @tree.children.last.options[:location] if result
        result
      end

      def update_tree(element)
        if element.type == :p && (raw = element.children.find { |child| child.type == :raw_text })
          raw.value.sub!(/\n+\z/, '')
          element.options[:prose_source] = raw.value.dup
          element.options[:prose_atoms] = raw.options[:prose_atoms] = []
          raw.options[:prose_atoms] << [0, 3] if raw.value.match?(/\A\[[ xX]\]/)
        end
        result = super
        if element.type == :p && element.children.all? do |child|
          child.type == :html_element || (child.type == :text && child.value.strip.empty?)
        end
          element.options.delete(:prose_source)
        end
        result
      end

      def parse_spans(element, *args, &)
        previous = @prose_atoms
        @prose_atoms = element.options[:prose_atoms] if element.type == :raw_text
        super
      ensure
        @prose_atoms = previous
      end

      def parse_list
        Kramdown::Parser::Kramdown.instance_method(:parse_list).bind_call(self)
      end

      def parse_link
        if @src.pos.zero? && @src.check(/\[[ xX]\]/)
          add_text(@src.scan(/\[[ xX]\]/))
        else
          capture_atom { super }
        end
      end

      %i[parse_codespan parse_autolink parse_span_html].each do |method|
        define_method(method) { capture_atom { super() } }
      end

      def capture_atom
        scanner = @src
        first = scanner.pos
        atoms = @prose_atoms
        result = yield
        if atoms
          atoms << [scanner.string.byteslice(0, first).length,
                    scanner.string.byteslice(0, scanner.pos).length]
        end
        result
      end
    end
  end
end
