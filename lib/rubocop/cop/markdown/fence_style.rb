# frozen_string_literal: true

require_relative '../../prose/code_rules'

module RuboCop
  module Cop
    module Markdown
      class FenceStyle < Base
        extend AutoCorrector
        include RuboCop::Prose::CodeRules

        private

        def investigate_document
          expected = { 'backtick' => '`', 'tilde' => '~' }[cop_config.fetch('Style', 'consistent')]
          code_blocks.each do |node|
            details = fence_details(node)
            next unless details

            expected ||= details[:opening][:fence][0]
            next if details[:opening][:fence][0] == expected

            range = fence_range(details[:first], details[:opening])
            prose_offense(range, message: "Use #{expected == '`' ? 'backtick' : 'tilde'} fences.") do |corrector|
              next if expected == '`' && details[:opening][:info].include?('`')

              length = [details[:opening][:fence].length, details[:closing][:fence].length,
                        node.value.scan(/#{Regexp.escape(expected)}+/).map(&:length).max.to_i + 1].max
              replacement = expected * length
              corrector.replace(processed_range(range), replacement)
              closing = fence_range(details[:last], details[:closing])
              corrector.replace(processed_range(closing), replacement)
            end
          end
        end
      end
    end
  end
end
