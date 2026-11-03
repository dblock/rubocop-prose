# frozen_string_literal: true

require 'lint_roller'
require 'tempfile'

module RuboCop
  module Prose
    class Plugin < LintRoller::Plugin
      def about
        LintRoller::About.new(
          name: 'rubocop-prose', version: VERSION,
          homepage: 'https://github.com/dblock/rubocop-prose',
          description: 'Lint Markdown prose, structure, and style.'
        )
      end

      def supported?(context)
        context.engine == :rubocop
      end

      def rules(_context)
        @configuration ||= Tempfile.new(['rubocop-prose', '.yml']).tap do |file|
          file.write(Prose.default_configuration.to_yaml)
          file.flush
        end
        LintRoller::Rules.new(type: :path, config_format: :rubocop, value: Pathname.new(@configuration.path))
      end
    end
  end
end
