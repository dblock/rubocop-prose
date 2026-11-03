# frozen_string_literal: true

module RuboCop
  module Prose
    class FileTypes
      attr_reader :patterns

      def self.default
        @default ||= new(Prose.default_configuration)
      end

      def initialize(configuration)
        @patterns = %i[markdown text].to_h do |format|
          name = format.to_s.capitalize
          settings = configuration.fetch(name, {})
          raise ValidationError, "#{name} must be a mapping." unless settings.is_a?(Hash)

          values = settings.fetch('Include') { self.class.default.patterns.fetch(format) }
          [format, validate(name, values)]
        end.freeze
        loaded_path = configuration.loaded_path if configuration.respond_to?(:loaded_path)
        @matchers = patterns.transform_values do |values|
          RuboCop::Config.new({ 'AllCops' => { 'Include' => values } }, loaded_path)
        end
      end

      def format(path)
        return unless path

        matches = @matchers.select { |_, matcher| matcher.file_to_include?(path) }.keys
        raise ValidationError, "#{path.inspect} matches both Markdown/Include and Text/Include." if matches.length > 1

        matches.first
      end

      private

      def validate(name, values)
        valid = values.is_a?(Array) && values.all? do |value|
          value.is_a?(Regexp) || (value.is_a?(String) && !value.empty?)
        end
        raise ValidationError, "#{name}/Include must be an array of nonempty file patterns." unless valid

        values.map { |value| value.dup.freeze }.uniq.freeze
      end
    end

    module Configuration
      def prose_file_types
        @prose_file_types ||= FileTypes.new(self)
      end
    end
  end
end

RuboCop::Config.prepend(RuboCop::Prose::Configuration)
