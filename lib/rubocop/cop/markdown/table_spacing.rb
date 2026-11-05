# frozen_string_literal: true

require_relative '../../prose/table_rules'

module RuboCop
  module Cop
    module Markdown
      class TableSpacing < Base
        extend AutoCorrector

        def validate_config
          styles = cop_config['SupportedStyles']
          return if styles.include?(cop_config['Style'])

          raise ValidationError, "#{cop_name}: Style must be one of #{styles.join(', ')}."
        end

        def investigate_document
          document.tables.each do |table|
            style = cop_config.fetch('Style', 'aligned')
            widths = table.rows.each_with_object({}) do |row, sizes|
              row.cells.each_with_index do |cell, index|
                sizes[index] = [sizes.fetch(index, 0), cell.text.strip.length].max
              end
            end
            table.rows.each do |row|
              row.cells.each_with_index do |cell, index|
                content = cell.text.strip
                left = row.leading || index.positive?
                right = row.trailing || index < row.cells.length - 1
                if content.empty?
                  padding = case style
                            when 'tight' then ''
                            when 'aligned' then ' ' * (widths[index] + (left ? 1 : 0) + (right ? 1 : 0))
                            else ' '
                            end
                  next if cell.text == padding

                  range = document.range(row.number, cell.begin_pos, row.number, cell.end_pos)
                  prose_offense(range, message: "Use #{style} table cell spacing.") do |corrector|
                    corrector.replace(processed_range(range), padding)
                  end
                  next
                end

                before = cell.text[/\A[ \t]*/]
                after = cell.text[/[ \t]*\z/]
                expected_before = left ? ' ' : ''
                padding = style == 'aligned' ? widths[index] - content.length + 1 : 1
                expected_after = right ? ' ' * padding : ''
                valid = case style
                        when 'tight' then before.empty? && after.empty?
                        else before == expected_before && after == expected_after
                        end
                next if valid

                replacement = style == 'tight' ? content : "#{expected_before}#{content}#{expected_after}"
                range = document.range(row.number, cell.begin_pos, row.number, cell.end_pos)
                prose_offense(range, message: "Use #{style} table cell spacing.") do |corrector|
                  corrector.replace(processed_range(range), replacement)
                end
              end
            end
          end
        end
      end
    end
  end
end
