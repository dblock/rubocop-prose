# frozen_string_literal: true

require_relative '../../prose/link_rules'

module RuboCop
  module Cop
    module Markdown
      class ReferenceDefinitions < Base
        def validate_config
          unless %w[forbid allow_identical allow].include?(cop_config['Duplicates'])
            raise ValidationError, "#{cop_name}: Duplicates must be forbid, allow_identical, or allow."
          end
          return if [true, false].include?(cop_config['Unused'])

          raise ValidationError, "#{cop_name}: Unused must be true or false."
        end

        private

        def investigate_document
          scanner = document.link_rules
          used = scanner.links.filter_map(&:reference).to_set
          ignored = cop_config.fetch('IgnoredDefinitions', ['//']).map { |label| scanner.normalize(label) }
          seen = {}
          scanner.definitions.each do |definition|
            first = seen[definition.reference]
            seen[definition.reference] ||= definition
            duplicate = first && cop_config['Duplicates'] != 'allow' &&
                        !(cop_config['Duplicates'] == 'allow_identical' &&
                        scanner.decode(first.destination) == scanner.decode(definition.destination) &&
                        first.title == definition.title)
            next if ignored.include?(definition.reference)

            message = if duplicate
                        'Remove or rename the duplicate reference definition.'
                      elsif !used.include?(definition.reference) && cop_config['Unused']
                        'Reference definition is not used.'
                      end
            next unless message

            prose_offense(scanner.range(definition.begin_pos, definition.end_pos), message: message)
          end
        end
      end
    end
  end
end
