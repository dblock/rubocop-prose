# frozen_string_literal: true

require_relative '../../prose/inline_rules'

module RuboCop
  module Cop
    module Prose
      class RawHtml < Base
        def investigate_document
          allowed = Array(cop_config['AllowedElements']).map(&:downcase)
          offsets = Hash.new(0)
          located = []
          unlocated = []
          descendants = ->(node) { [node] + node.children.flat_map { |child| descendants.call(child) } }
          table_nodes = document.nodes(:table).flat_map { |table| descendants.call(table) }.to_set
          document.nodes(:html_element).each do |node|
            number = node.options[:location]
            if !number || table_nodes.include?(node)
              unlocated << node.value.to_s.downcase
              next
            end
            next unless number && !document.front_matter_line?(number) && !document.code_line?(number)

            text = document.line(number)
            key = [number, node.value.to_s.downcase]
            match = /<#{Regexp.escape(node.value.to_s)}\b[^>]*(?:>|\z)/i.match(text, offsets[key])
            unless match
              unlocated << node.value.to_s.downcase
              next
            end

            offsets[key] = match.end(0)
            located << [number, match.begin(0)]
            next if allowed.include?(node.value.to_s.downcase)

            prose_offense(document.range(number, match.begin(0), number, match.end(0)),
                          message: "Raw HTML element <#{node.value}> is not allowed.")
          end
          # GFM table cell span locations are relative to the cell, not the document.
          RuboCop::Prose::InlineRules.lines(document).each do |text, number, _|
            protected = RuboCop::Prose::InlineRules.spans(text).reject { |span| span.kind == :html }
            text.to_enum(:scan, /<([A-Za-z][\w:-]*)\b[^>]*>/).each do
              match = Regexp.last_match
              name = match[1].downcase
              next unless unlocated.include?(name)
              next if located.include?([number, match.begin(0)])
              next if protected.any? { |span| match.begin(0) >= span.begin_pos && match.begin(0) < span.end_pos }

              unlocated.delete_at(unlocated.index(name))
              next if allowed.include?(name)

              prose_offense(document.range(number, match.begin(0), number, match.end(0)),
                            message: "Raw HTML element <#{match[1]}> is not allowed.")
            end
          end
        end
      end
    end
  end
end
