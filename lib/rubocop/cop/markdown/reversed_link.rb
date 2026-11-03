# frozen_string_literal: true

require_relative '../../prose/link_rules'

module RuboCop
  module Cop
    module Markdown
      class ReversedLink < Base
        MSG = 'Use [link text](destination), not (link text)[destination].'

        private

        def investigate_document
          scanner = document.link_rules
          scanner.reversed_links.each { |first, last| prose_offense(scanner.range(first, last)) }
        end
      end
    end
  end
end
