# frozen_string_literal: true

require_relative '../../prose/link_rules'

module RuboCop
  module Cop
    module Markdown
      class LinkFragment < Prose::Base
        MSG = 'Link fragment does not identify a heading or HTML anchor in this document.'

        private

        def investigate_document
          renderer = cop_config.fetch('Renderer', 'github')
          raise ArgumentError, "Unknown anchor renderer: #{renderer}" unless %w[github gitlab
                                                                                kramdown].include?(renderer)

          scanner = RuboCop::Prose::LinkRules.new(document)
          anchors = scanner.anchors(renderer, cop_config.fetch('AdditionalAnchors', []))
          scanner.links.each do |link|
            next if link.image || !scanner.resolved?(link)

            target = scanner.destination(link)
            next unless target&.start_with?('#')
            next if target == '#' && cop_config.fetch('AllowEmptyFragment', true)

            fragment = URI::DEFAULT_PARSER.unescape(target[1..])
            next if anchors.include?(fragment)

            prose_offense(scanner.link_range(link))
          end
        end
      end
    end
  end
end
