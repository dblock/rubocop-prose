# frozen_string_literal: true

require_relative '../../prose/code_rules'

module RuboCop
  module Cop
    module Markdown
      class FenceLanguage < Base
        include RuboCop::Prose::CodeRules

        def validate_config
          %w[AllowedLanguages DisallowedLanguages].each do |name|
            values = cop_config.fetch(name, [])
            next if values.is_a?(Array) && values.all?(String)

            raise ValidationError, "Markdown/FenceLanguage: #{name} must be an array of language names."
          end
          return if cop_config.fetch('AllowedLanguages', []).empty? ||
                    cop_config.fetch('DisallowedLanguages', []).empty?

          raise ValidationError, 'Markdown/FenceLanguage: configure AllowedLanguages or DisallowedLanguages, not both.'
        end

        private

        def investigate_document
          allowed = cop_config.fetch('AllowedLanguages', [])
          disallowed = cop_config.fetch('DisallowedLanguages', [])
          code_blocks.each do |node|
            next unless node.options[:fenced]

            language = node.options[:lang].to_s
            next unless language.empty? || disallowed.include?(language) ||
                        (!allowed.empty? && !allowed.include?(language))

            message = if language.empty?
                        'Specify a language for this fenced code block.'
                      elsif disallowed.include?(language)
                        "Do not use the disallowed fence language '#{language}'."
                      else
                        "Use an allowed fence language (#{allowed.join(', ')})."
                      end
            prose_offense(document.line_range(node.options[:location]), message: message)
          end
        end
      end
    end
  end
end
