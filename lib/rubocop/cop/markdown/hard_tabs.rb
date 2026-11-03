# frozen_string_literal: true

module RuboCop
  module Cop
    module Markdown
      class HardTabs < Base
        private

        def investigate_document
          allowed = cop_config['AllowedCodeLanguages'].map(&:downcase)
          exempt = document.nodes(:codeblock).flat_map do |block|
            next [] unless allowed.include?(block.options[:lang].to_s.split.first.to_s.downcase)

            first = block.options.fetch(:code_start_line)
            (first...(first + block.value.lines.length)).to_a
          end.to_set
          document.lines.each_with_index do |text, index|
            number = index + 1
            next if document.front_matter_line?(number) || exempt.include?(number)
            next if document.code_line?(number) && !cop_config['CodeBlocks']

            text.to_enum(:scan, /\t/).each do
              position = Regexp.last_match.begin(0)
              prose_offense(document.range(number, position, number, position + 1),
                            message: 'Use spaces instead of hard tabs.')
            end
          end
        end
      end
    end
  end
end
