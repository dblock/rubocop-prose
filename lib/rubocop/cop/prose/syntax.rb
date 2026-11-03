# frozen_string_literal: true

module RuboCop
  module Cop
    module Prose
      class Syntax < Base
        private

        def investigate_document
          document.warnings.reject { |warning| owned_elsewhere?(warning) }
                  .group_by { |warning| warning_line(warning) }.each do |number, warnings|
            prose_offense(document.line_range(number), message: warnings.join('; '))
          end
        end

        def owned_elsewhere?(warning)
          (warning.start_with?('No link definition') && config['Prose/UndefinedReference']&.fetch('Enabled', false)) ||
            (warning.start_with?('Duplicate link ID') && config['Prose/ReferenceDefinitions']&.fetch('Enabled', false))
        end

        def warning_line(warning)
          number = warning.scan(/\bline (\d+)\b/).last&.first&.to_i || 1
          number.clamp(1, document.lines.length)
        end
      end
    end
  end
end
