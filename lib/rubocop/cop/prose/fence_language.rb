# frozen_string_literal: true

require_relative '../../prose/code_rules'

module RuboCop
  module Cop
    module Prose
      class FenceLanguage < Base
        include RuboCop::Prose::CodeRules

        private

        def investigate_document
          allowed = cop_config.fetch('AllowedLanguages', [])
          code_blocks.each do |node|
            next unless node.options[:fenced]

            language = node.options[:lang].to_s
            next unless language.empty? || (!allowed.empty? && !allowed.include?(language))

            message = if language.empty?
                        'Specify a language for this fenced code block.'
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
