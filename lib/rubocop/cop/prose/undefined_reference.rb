# frozen_string_literal: true

require_relative '../../prose/link_rules'

module RuboCop
  module Cop
    module Prose
      class UndefinedReference < Base
        MSG = 'Define the link or image reference.'

        private

        def investigate_document
          scanner = RuboCop::Prose::LinkRules.new(document)
          scanner.links.each do |link|
            next unless link.reference && !scanner.resolved?(link)
            next if link.style == 'shortcut_reference' && !cop_config.fetch('ShortcutSyntax', false)

            prose_offense(scanner.link_range(link))
          end
        end
      end
    end
  end
end
