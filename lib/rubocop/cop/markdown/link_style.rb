# frozen_string_literal: true

require_relative '../../prose/link_rules'

module RuboCop
  module Cop
    module Markdown
      class LinkStyle < Base
        MSG = 'Use an allowed %<kind>s style instead of %<style>s.'

        private

        def investigate_document
          scanner = document.link_rules
          scanner.links.each do |link|
            next unless scanner.resolved?(link)

            key = link.image ? 'AllowedImageStyles' : 'AllowedLinkStyles'
            allowed = cop_config.fetch(key, %w[inline reference autolink])
            next if allowed.include?(link.style) || (link.reference && allowed.include?('reference'))

            prose_offense(scanner.link_range(link),
                          message: format(MSG, kind: link.image ? 'image' : 'link', style: link.style))
          end
        end
      end
    end
  end
end
