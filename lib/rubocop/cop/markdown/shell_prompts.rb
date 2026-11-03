# frozen_string_literal: true

require_relative '../../prose/code_rules'

module RuboCop
  module Cop
    module Markdown
      class ShellPrompts < Base
        extend AutoCorrector
        include RuboCop::Prose::CodeRules

        private

        def investigate_document
          languages = cop_config.fetch('ShellLanguages', %w[bash console ksh sh shell zsh])
          code_blocks.each do |node|
            next unless node.options[:fenced] && languages.include?(node.options[:lang])

            commands = node.value.lines.map(&:chomp).reject { |line| line.strip.empty? }
            next if commands.empty? || commands.any? { |line| !line.start_with?('$ ') }

            safe = prompt_correction_safe?(node, commands)
            node.value.lines.each_with_index do |line, index|
              next unless line.start_with?('$ ')

              range = code_content_range(node, index, 2)
              next unless range

              prose_offense(range, message: 'Omit shell prompts when the example contains no output.') do |corrector|
                corrector.remove(processed_range(range)) if safe
              end
            end
          end
        end

        def prompt_correction_safe?(node, commands)
          details = fence_details(node)
          return false unless details

          fence = details[:opening][:fence]
          closing = /\A[ \t]{0,3}#{Regexp.escape(fence[0])}{#{fence.length},}[ \t]*\z/
          commands.none? { |command| command.delete_prefix('$ ').match?(closing) }
        end
      end
    end
  end
end
