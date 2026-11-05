# frozen_string_literal: true

require 'psych'

module RuboCop
  module Cop
    module Markdown
      class FrontMatterKeys < Base
        def validate_config
          %w[AllowedKeys RequiredKeys].each do |option|
            keys = cop_config[option]
            next if option == 'AllowedKeys' && keys.nil?
            next if keys.is_a?(Array) && keys.all? { |key| key.is_a?(String) && !key.empty? }

            raise ValidationError, "#{cop_name}: #{option} must be an array of nonempty key names."
          end
          allowed = cop_config['AllowedKeys']
          return if allowed.nil? || (cop_config['RequiredKeys'] - allowed).empty?

          raise ValidationError, "#{cop_name}: RequiredKeys must be included in AllowedKeys."
        end

        private

        def investigate_document
          return unless document.front_matter

          parsed = parse_front_matter
          return if parsed == :invalid

          root = parsed&.root
          if root && !root.is_a?(Psych::Nodes::Mapping)
            prose_offense(node_range(root), message: 'Front matter must be a mapping of metadata keys.')
            return
          end

          keys = root ? root.children.each_slice(2).map(&:first) : []
          names = keys.filter_map do |key|
            unless key.is_a?(Psych::Nodes::Scalar)
              prose_offense(node_range(key), message: 'Front matter keys must be scalar names.')
              next
            end

            allowed = cop_config['AllowedKeys']
            if allowed && !allowed.include?(key.value)
              prose_offense(node_range(key), message: "Front matter key `#{key.value}` is not allowed.")
            end
            key.value
          end
          (cop_config['RequiredKeys'] - names).each do |key|
            prose_offense(document.line_range(1), message: "Missing required front matter key `#{key}`.")
          end
        end

        def parse_front_matter
          Psych.parse(document.front_matter.lines[1...-1].join) || nil
        rescue Psych::SyntaxError
          # Syntax diagnostics belong to Markdown/FrontMatterSyntax.
          :invalid
        end

        def node_range(node)
          first = node.start_line + 2
          last = node.end_line + 2
          document.range(first, node.start_column, last, node.end_column)
        end
      end
    end
  end
end
