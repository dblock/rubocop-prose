# frozen_string_literal: true

module RuboCop
  module Cop
    module Markdown
      class StructuralLineLength < Prose::Base
        MSG = 'Markdown source line is too long. [%<length>d/%<max>d]'

        def validate_config
          %w[Max HeadingMax CodeBlockMax].each do |name|
            value = cop_config[name]
            next if name != 'Max' && value.nil?
            next if value.is_a?(Integer) && value.positive?

            raise ValidationError, "Markdown/StructuralLineLength: #{name} must be a positive integer."
          end
        end

        private

        def investigate_document
          table_lines = document.nodes(:table).flat_map do |table|
            first = table.options.fetch(:location)
            rows = table.children.sum { |section| section.children.length }
            (first..(first + rows)).to_a
          end.to_set
          headings = document.headings.to_set(&:last)
          document.lines.each_with_index do |text, index|
            number = index + 1
            next if document.front_matter_line?(number)

            limit = structural_limit(number, headings, table_lines)
            next unless limit && text.length > limit

            prose_offense(document.range(number, limit), message: format(MSG, length: text.length, max: limit))
          end
        end

        def structural_limit(number, headings, tables)
          if headings.include?(number) && cop_config['Headings']
            cop_config['HeadingMax'] || cop_config['Max']
          elsif document.code_line?(number) && cop_config['CodeBlocks']
            cop_config['CodeBlockMax'] || cop_config['Max']
          elsif tables.include?(number) && cop_config['Tables']
            cop_config['Max']
          end
        end
      end
    end
  end
end
