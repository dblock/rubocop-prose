# frozen_string_literal: true

require_relative '../../prose/heading_rules'

module RuboCop
  module Cop
    module Markdown
      class DuplicateHeadings < Base
        include RuboCop::Prose::HeadingRules

        def validate_config
          scopes = ['siblings', 'document', false]
          value = cop_config['Scope']
          return if scopes.include?(value)

          if value.is_a?(Hash) && value.key?('Default') && scopes.include?(value['Default'])
            covered = []
            valid = value.except('Default').all? do |selector, scope|
              levels = selector_levels(selector)
              next false unless levels && scopes.include?(scope) && !covered.intersect?(levels)

              covered.concat(levels)
              true
            end
            return if valid
          end

          raise ValidationError, "#{cop_name}: Scope must be siblings, document, false, or a mapping with Default " \
                                 'and nonoverlapping levels (1-6), ranges (4-6), or comparisons (>4), ' \
                                 'set to siblings, document, or false.'
        end

        def investigate_document
          document_seen = Set.new
          sibling_seen = Set.new
          parents = []
          heading_entries.each do |heading|
            parents.pop while parents.any? && parents.last[:level] >= heading[:level]
            key = [parents.last&.fetch(:line), heading[:text]]
            setting = cop_config['Scope']
            scope = effective_scope(setting, heading[:level])
            duplicate = scope == 'document' ? document_seen.include?(heading[:text]) : sibling_seen.include?(key)
            if scope != false && duplicate
              prose_offense(heading_range(heading), message: 'Use unique heading text within the configured scope.')
            end
            document_seen.add(heading[:text])
            sibling_seen.add(key)
            parents << heading
          end
        end

        private

        def effective_scope(setting, level)
          return setting unless setting.is_a?(Hash)

          selected = setting.find do |selector, _scope|
            selector != 'Default' && selector_levels(selector).include?(level)
          end
          selected ? selected.last : setting.fetch('Default')
        end

        def selector_levels(selector)
          return [selector] if selector.is_a?(Integer) && selector.between?(1, 6)
          return unless selector.is_a?(String)

          if (match = /\A([1-6])-([1-6])\z/.match(selector))
            first, last = match.captures.map(&:to_i)
            (first..last).to_a if first <= last
          elsif (match = /\A([<>])([1-6])\z/.match(selector))
            levels = (1..6).select { |level| match[1] == '>' ? level > match[2].to_i : level < match[2].to_i }
            levels unless levels.empty?
          end
        end
      end
    end
  end
end
