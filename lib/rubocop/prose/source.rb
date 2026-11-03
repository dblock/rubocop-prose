# frozen_string_literal: true

module RuboCop
  module Prose
    module Source
      DIRECTIVE = %r{(?:<!--|<span\b[^>]*>)\s*(#\s*rubocop:[^\n]*?)\s*(?:-->|</span>)}

      module MarkdownMapping
        def markdown_document
          super unless prose_format == :text
        end
      end

      module Parsing
        private

        def parse(source, *)
          return super unless prose_format

          if prose_format == :markdown && respond_to?(:markdown_document)
            super
            return if prose_markdown_document

            @diagnostics.clear
            @parser_error = @tokens = nil
          end

          super('', *)
          @buffer = ::Parser::Source::Buffer.new(path, source: raw_source)
          @prose_documents = @prose_comments = nil
        end
      end

      attr_reader :prose_format

      def initialize(source, ruby_version, path = nil, prose_configuration: nil, **)
        @prose_format = Document.format(path, prose_configuration)
        extend Parsing if prose_format
        extend MarkdownMapping if prose_format == :text && respond_to?(:markdown_document)
        super(source, ruby_version, path, **)
      end

      def prose_document(configuration: nil)
        @prose_documents ||= {}.compare_by_identity
        @prose_documents[configuration] ||= Document.build(
          path,
          prose_markdown_document ? prose_markdown_document.buffer : buffer,
          configuration: configuration, format: prose_format
        )
      end

      def valid_syntax?
        prose_format && !prose_markdown_document ? false : super
      end

      def comments
        return [] if prose_format == :text
        return super unless prose_format && !prose_markdown_document

        prose_comments
      end

      def prose_markdown_document
        markdown_document if prose_format == :markdown && respond_to?(:markdown_document)
      end

      private

      def prose_comments
        @prose_comments ||= buffer.source.to_enum(:scan, DIRECTIVE).filter_map do
          match = Regexp.last_match
          range = ::Parser::Source::Range.new(buffer, match.begin(1), match.end(1))
          next if prose_document.code_line?(range.first_line) || prose_document.front_matter_line?(range.first_line)

          ::Parser::Source::Comment.new(range)
        end
      end
    end
  end
end

RuboCop::ProcessedSource.prepend(RuboCop::Prose::Source)
