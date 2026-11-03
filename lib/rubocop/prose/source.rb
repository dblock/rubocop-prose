# frozen_string_literal: true

module RuboCop
  module Prose
    module Source
      DIRECTIVE = %r{(?:<!--|<span\b[^>]*>)\s*(#\s*rubocop:[^\n]*?)\s*(?:-->|</span>)}

      def prose_document(ignore_front_matter: true)
        @prose_documents ||= {}
        @prose_documents[ignore_front_matter] ||= Document.build(
          path,
          prose_markdown_document ? prose_markdown_document.buffer : buffer,
          ignore_front_matter: ignore_front_matter
        )
      end

      def valid_syntax?
        Document.file?(path) && !prose_markdown_document ? false : super
      end

      def comments
        return [] if TextDocument.file?(path)
        return super unless Document.file?(path) && !prose_markdown_document

        prose_comments
      end

      def prose_markdown_document
        markdown_document if MarkdownDocument.file?(path) && respond_to?(:markdown_document)
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

      def parse(source, *)
        return super unless Document.file?(path)
        return super if MarkdownDocument.file?(path) && respond_to?(:markdown_document)

        super('', *)
        @buffer = ::Parser::Source::Buffer.new(path, source: source)
        @prose_documents = @prose_comments = nil
      end
    end
  end
end

RuboCop::ProcessedSource.prepend(RuboCop::Prose::Source)
