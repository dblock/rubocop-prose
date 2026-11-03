# frozen_string_literal: true

require_relative '../../prose/link_rules'

module RuboCop
  module Cop
    module Markdown
      class ReferenceDefinitions < Base
        private

        def investigate_document
          scanner = RuboCop::Prose::LinkRules.new(document)
          used = scanner.links.filter_map(&:reference).to_set
          ignored = cop_config.fetch('IgnoredDefinitions', ['//']).map { |label| scanner.normalize(label) }
          seen = Set.new
          scanner.definitions.each do |definition|
            duplicate = !seen.add?(definition.reference)
            next if ignored.include?(definition.reference)

            message = if duplicate && cop_config.fetch('CheckDuplicates', true)
                        'Remove or rename the duplicate reference definition.'
                      elsif !used.include?(definition.reference) && cop_config.fetch('CheckUnused', false)
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
