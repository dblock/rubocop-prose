# frozen_string_literal: true

require_relative '../../prose/link_rules'

module RuboCop
  module Cop
    module Markdown
      class DescriptiveLinkText < Prose::Base
        MSG = 'Use descriptive link text instead of a generic label.'

        private

        def investigate_document
          scanner = RuboCop::Prose::LinkRules.new(document)
          generic = cop_config.fetch('GenericLabels', ['click here', 'here', 'link', 'more'])
                              .map { |label| scanner.normalize_text(label) }
          scanner.links.each do |link|
            next if link.image || link.style == 'autolink' || !scanner.resolved?(link)
            next unless generic.include?(scanner.normalize_text(scanner.display_text(link)))

            prose_offense(scanner.label_range(link))
          end
        end
      end
    end
  end
end
