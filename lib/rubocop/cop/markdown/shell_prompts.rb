# frozen_string_literal: true

require_relative '../../prose/code_rules'

module RuboCop
  module Cop
    module Markdown
      class ShellPrompts < Base
        extend AutoCorrector
        include RuboCop::Prose::CodeRules

        def validate_config
          %w[ShellLanguages Prompts].each do |name|
            value = cop_config[name]
            next if value.is_a?(Array) && (name != 'Prompts' || !value.empty?) &&
                    value.all? { |entry| entry.is_a?(String) && entry.match?(/\A\S+\z/) }

            raise ValidationError, "Markdown/ShellPrompts: #{name} must be an array of nonempty strings " \
                                   'without whitespace (and Prompts must contain at least one marker).'
          end
        end

        private

        def investigate_document
          languages = cop_config.fetch('ShellLanguages')
          code_blocks.each do |node|
            next unless node.options[:fenced] && languages.include?(node.options[:lang])

            commands = prompted_commands(node)
            next if commands.nil? || commands.empty?

            safe = prompt_correction_safe?(node, commands)
            commands.each do |_, index, prompt|
              range = code_content_range(node, index, prompt.length + 1)
              next unless range

              prose_offense(range, message: 'Omit shell prompts when the example contains no output.') do |corrector|
                corrector.remove(processed_range(range)) if safe
              end
            end
          end
        end

        def prompted_commands(node)
          commands = []
          node.value.lines.each_with_index do |line, index|
            line = line.chomp
            prompt = cop_config.fetch('Prompts').find { |marker| line.start_with?("#{marker} ") }
            if prompt
              commands << [line, index, prompt]
            elsif !line.strip.empty? && !line.lstrip.start_with?('#')
              return nil
            end
          end
          commands
        end

        def prompt_correction_safe?(node, commands)
          return false if commands.any? { |_, _, prompt| prompt.start_with?('#') }

          details = fence_details(node)
          return false unless details

          fence = details[:opening][:fence]
          closing = /\A[ \t]{0,3}#{Regexp.escape(fence[0])}{#{fence.length},}[ \t]*\z/
          commands.none? { |command, _, prompt| command.delete_prefix("#{prompt} ").match?(closing) }
        end
      end
    end
  end
end
