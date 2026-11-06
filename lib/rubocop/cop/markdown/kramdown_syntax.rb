# frozen_string_literal: true

module RuboCop
  module Cop
    module Markdown
      class KramdownSyntax < Base
        private

        def investigate_document
          document.warnings.reject { |warning| owned_elsewhere?(warning) }
                  .group_by { |warning| warning_line(warning) }.each do |number, warnings|
            prose_offense(document.line_range(number), message: warnings.join('; '))
          end
        end

        def owned_elsewhere?(warning)
          owner = if warning.start_with?('No link definition')
                    'Markdown/UndefinedReference'
                  elsif warning.start_with?('Duplicate link ID')
                    'Markdown/ReferenceDefinitions'
                  end
          owner && config.cop_enabled?(owner) &&
            processed_source.registry&.any? { |cop| cop.cop_name == owner }
        end

        def warning_line(warning)
          number = warning.scan(/\bline (\d+)\b/).last&.first&.to_i || 1
          number.clamp(1, document.lines.length)
        end
      end
    end
  end
end
