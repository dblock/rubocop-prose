# frozen_string_literal: true

require_relative '../../prose/link_rules'

module RuboCop
  module Cop
    module Prose
      class EmptyLink < Base
        MSG = 'Provide a nonempty link destination.'

        private

        def investigate_document
          scanner = RuboCop::Prose::LinkRules.new(document)
          scanner.links.each do |link|
            next if link.image || !scanner.resolved?(link)
            next unless ['', '#'].include?(scanner.destination(link))

            prose_offense(scanner.link_range(link))
          end
        end
      end
    end
  end
end
