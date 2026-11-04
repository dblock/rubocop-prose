# frozen_string_literal: true

require 'psych'

module RuboCop
  module Cop
    module Markdown
      class FrontMatterSyntax < Base
        private

        def investigate_document
          return unless document.front_matter

          Psych.parse(document.front_matter.lines[1...-1].join)
        rescue Psych::SyntaxError => e
          line = (e.line + 1).clamp(1, document.lines.length)
          column = (e.column - 1).clamp(0, document.line(line).length)
          prose_offense(
            document.range(line, column, line, [column + 1, document.line(line).length].min),
            message: "Invalid YAML front matter: #{e.problem}."
          )
        end
      end
    end
  end
end
