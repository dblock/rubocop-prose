# frozen_string_literal: true

require_relative '../../prose/proper_name_rules'

module RuboCop
  module Cop
    module Text
      class ProperNames < Base
        include RuboCop::Prose::ProperNameRules
        extend AutoCorrector

        private

        def name_lines
          document.lines.each_with_index.map { |text, index| [text, index + 1, 0] }
        end
      end
    end
  end
end
