# frozen_string_literal: true

require_relative 'heading_rules'
require_relative 'code_rules'
require_relative 'list_rules'
require_relative 'table_rules'

module RuboCop
  module Prose
    class StructuralBlankLines
      include HeadingRules
      include CodeRules
      include ListRules

      def initialize(document, configuration, processed_source)
        @document = document
        @configuration = configuration
        @processed_source = processed_source
      end

      def protected_lines
        @protected_lines = Set.new
        heading_boundaries if enabled?(Cop::Markdown::HeadingBlankLines)
        fence_boundaries if enabled?(Cop::Markdown::FenceBlankLines)
        list_boundaries if enabled?(Cop::Markdown::ListBlankLines)
        table_boundaries if enabled?(Cop::Markdown::TableBlankLines)
        @protected_lines
      end

      private

      attr_reader :document

      def enabled?(cop)
        @configuration.cop_enabled?(cop.cop_name) &&
          cop.new(@configuration).relevant_file?(@processed_source.file_path)
      end

      def heading_boundaries
        settings = @configuration.for_cop('Markdown/HeadingBlankLines')
        heading_entries.each do |heading|
          protect(heading[:line] - 1, -1, settings.fetch('LinesAbove', 1), blank: method(:heading_blank?))
          protect(heading[:last_line] + 1, 1, settings.fetch('LinesBelow', 1), blank: method(:heading_blank?))
        end
      end

      def fence_boundaries
        settings = @configuration.for_cop('Markdown/FenceBlankLines')
        fenced_blocks(list_items: settings.fetch('ListItems', true)) do |details|
          unless details[:opening][:prefix].match?(/[-+*]|\d+[.)]/)
            protect(details[:first] - 1, -1, settings.fetch('LinesAbove', 1))
          end
          protect(details[:last] + 1, 1, settings.fetch('LinesBelow', 1))
        end
      end

      def list_boundaries
        list_groups do |list, marks, parent|
          next if parent

          protect(marks.first[:line] - 1, -1, 1)
          protect(node_last_line(list) + 1, 1, 1)
        end
      end

      def table_boundaries
        TableRules.tables(document).each do |table|
          protect(table.rows.first.number - 1, -1, 1, front_matter: false)
          protect(table.rows.last.number + 1, 1, 1)
        end
      end

      def protect(number, direction, required, blank: method(:container_blank?), front_matter: true)
        return if required.zero?

        blanks = []
        while number.between?(1, document.lines.length)
          return if front_matter && direction.negative? && document.front_matter_line?(number)
          break unless blank.call(number)

          blanks << number
          number += direction
        end
        return unless number.between?(1, document.lines.length)

        # Marker-only lines already satisfy part of the structural minimum and are never removed.
        empty, marked = blanks.partition { |line| document.line(line).strip.empty? }
        @protected_lines.merge(empty.sort.first([required - marked.length, 0].max))
      end
    end
  end
end
