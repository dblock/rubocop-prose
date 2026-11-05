# frozen_string_literal: true

module RuboCop
  module Prose
    module ProperNameRules
      private

      def investigate_document
        names = Array(cop_config['Names']).reject(&:empty?)
        return if names.empty?

        alternatives = names.sort_by { |name| -name.length }.map { |name| Regexp.escape(name) }.join('|')
        pattern = /(?<![\p{L}\p{N}_])(?:#{alternatives})(?![\p{L}\p{N}_])/i
        name_lines.each do |text, number, column|
          text.to_enum(:scan, pattern).each do
            match = Regexp.last_match
            next if match.begin(0) < column

            expected = names.find { |name| name.casecmp?(match[0]) }
            next if match[0] == expected

            range = document.range(number, match.begin(0), number, match.end(0))
            prose_offense(range, message: "Use the capitalization `#{expected}`.") do |corrector|
              corrector.replace(processed_range(range), expected)
            end
          end
        end
      end
    end
  end
end
