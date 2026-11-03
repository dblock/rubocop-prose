# frozen_string_literal: true

require_relative '../../prose/link_rules'

module RuboCop
  module Cop
    module Markdown
      class BareUrl < Base
        MSG = 'Use an autolink or a Markdown link instead of a bare URL.'

        private

        def investigate_document
          scanner = document.link_rules
          scanner.bare_urls(cop_config.fetch('Schemes', %w[http https ftp])).each do |first, last|
            prose_offense(scanner.range(first, last))
          end
        end
      end
    end
  end
end
