# frozen_string_literal: true

require_relative '../../prose/inline_rules'

module RuboCop
  module Cop
    module Markdown
      class RawHtml < Base
        OPENING_TAG = /<([A-Za-z][\w:-]*)\b(?:[^"'<>]|"[^"]*"|'[^']*')*(?:>|\z)/
        ATTRIBUTE = /\s+([a-z_:][\w:.-]*)(?:\s*=\s*(?:"[^"]*"|'[^']*'|[^\s"'=<>`]+))?/i

        def validate_config
          allowed_elements
        end

        def investigate_document
          allowed = allowed_elements
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
            match = opening_tag(text, node.value, offsets[key])
            unless match
              unlocated << node.value.to_s.downcase
              next
            end

            offsets[key] = match.end(0)
            located << [number, match.begin(0)]
            next if element_allowed?(node.value, match[0], allowed)

            prose_offense(document.range(number, match.begin(0), number, match.end(0)),
                          message: "Raw HTML element <#{node.value}> is not allowed.")
          end
          # GFM table cell span locations are relative to the cell, not the document.
          document.inline_lines.each do |text, number, _|
            protected = document.inline_spans(number).reject { |span| span.kind == :html }
            text.to_enum(:scan, OPENING_TAG).each do
              match = Regexp.last_match
              name = match[1].downcase
              next unless unlocated.include?(name)
              next if located.include?([number, match.begin(0)])
              next if protected.any? { |span| match.begin(0) >= span.begin_pos && match.begin(0) < span.end_pos }

              unlocated.delete_at(unlocated.index(name))
              next if element_allowed?(name, match[0], allowed)

              prose_offense(document.range(number, match.begin(0), number, match.end(0)),
                            message: "Raw HTML element <#{match[1]}> is not allowed.")
            end
          end
        end

        private

        def allowed_elements
          configured = cop_config.fetch('AllowedElements', [])
          unless configured.is_a?(Array)
            raise ValidationError,
                  'Markdown/RawHtml: AllowedElements must be an array of element names or attribute rules.'
          end

          configured.map do |entry|
            if entry.is_a?(String) && entry.match?(/\A[a-z][\w:-]*\z/i)
              [entry.downcase, nil]
            elsif entry.is_a?(Hash) && entry.size == 1
              attribute_rule(*entry.first)
            else
              raise ValidationError, 'Markdown/RawHtml: AllowedElements entries must be element names or ' \
                                     'single-element mappings to attribute lists.'
            end
          end
        end

        def attribute_rule(element, attributes)
          unless element.is_a?(String) && element.match?(/\A[a-z][\w:-]*\z/i)
            raise ValidationError, 'Markdown/RawHtml: AllowedElements rules must use valid element names.'
          end

          unless attributes.is_a?(Array) &&
                 attributes.all? { |attribute| attribute.is_a?(String) && attribute.match?(/\A[a-z_:][\w:.-]*\z/i) }
            raise ValidationError, 'Markdown/RawHtml: Attribute rules must be arrays of attribute names.'
          end

          [element.downcase, attributes.map(&:downcase)]
        end

        def opening_tag(text, name, offset)
          pattern = /<#{Regexp.escape(name.to_s)}\b(?:[^"'<>]|"[^"]*"|'[^']*')*(?:>|\z)/i
          pattern.match(text, offset)
        end

        def element_allowed?(name, tag, allowed)
          present = tag.scan(ATTRIBUTE).flatten.map(&:downcase)
          allowed.any? do |element, attributes|
            next false unless element == name.to_s.downcase

            attributes.nil? || present.all? { |attribute| attributes.include?(attribute) }
          end
        end
      end
    end
  end
end
