# frozen_string_literal: true

require_relative '../../prose/link_rules'

module RuboCop
  module Cop
    module Markdown
      class DescriptiveLinkText < Base
        MSG = 'Use descriptive link text instead of a generic label.'

        def validate_config
          words = cop_config.fetch('NonDescriptiveWords', [])
          return if words.is_a?(Array) &&
                    words.all? { |word| word.is_a?(String) && word.scan(/[^[:space:]]+/).one? }

          raise ValidationError,
                'Markdown/DescriptiveLinkText: NonDescriptiveWords must be an array of individual nonempty words.'
        end

        private

        def investigate_document
          scanner = document.link_rules
          generic = cop_config.fetch('GenericLabels', ['click here', 'here', 'link', 'more'])
                              .map { |label| scanner.normalize_text(label) }
          words = cop_config.fetch('NonDescriptiveWords', []).to_set { |word| scanner.normalize_text(word) }
          scanner.links.each do |link|
            next if link.image || link.style == 'autolink' || !scanner.resolved?(link)

            label = scanner.normalize_text(scanner.display_text(link))
            next unless generic.include?(label) || only_generic_words?(label, words)

            prose_offense(scanner.label_range(link))
          end
        end

        def only_generic_words?(label, words)
          return false if words.empty? || label.empty?

          label.split.all? { |word| words.include?(word) }
        end
      end
    end
  end
end
