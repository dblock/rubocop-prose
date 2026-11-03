# frozen_string_literal: true

module RuboCop
  module Prose
    module Runner
      private

      def get_processed_source(file, *arguments, **keywords)
        configuration = @config_store.for_file(file)
        format = configuration.prose_file_types.format(file)
        return super if format == Document.format(file)

        # The native factory normally initializes this optional preprocessor context.
        if defined?(RuboCop::Markdown) && RuboCop::Markdown.respond_to?(:config_store=)
          RuboCop::Markdown.config_store = @config_store
        end

        source = if keywords[:source]
                   RuboCop::Util.emulate_write_read_cycle(keywords[:source])
                 else
                   prose_source(file)
                 end
        processed = ProcessedSource.new(
          source, configuration.target_ruby_version, file,
          parser_engine: configuration.parser_engine, prose_configuration: configuration
        )
        processed.config = configuration
        processed.registry = mobilized_cop_classes(configuration)
        processed
      end

      def prose_source(file)
        @options[:stdin] || File.binread(file)
      rescue Errno::ENOENT
        raise RuboCop::Error, "No such file or directory: #{file}"
      end
    end

    module TargetFinder
      def find(...)
        @config_store.for_pwd.prose_file_types
        super
      end

      private

      def ruby_file?(file, ...)
        types = @config_store.for_file(file).prose_file_types
        super || !types.format(file).nil?
      end

      def to_inspect?(file, ...)
        configuration = @config_store.for_file(file)
        return false if configuration.prose_file_types.format(file) && configuration.file_to_exclude?(file)

        super
      end
    end
  end
end

RuboCop::Runner.prepend(RuboCop::Prose::Runner)
RuboCop::TargetFinder.prepend(RuboCop::Prose::TargetFinder)
