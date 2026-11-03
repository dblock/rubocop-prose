# frozen_string_literal: true

module RuboCop
  module Cop
    module Prose
      class Base < RuboCop::Cop::Base
        exclude_from_registry

        def on_new_investigation
          super
          @document = nil
          investigate_document if applicable_document?
        end

        def on_other_file
          on_new_investigation
        end

        def current_corrector
          return super unless RuboCop::Prose::Document.file?(processed_source.path)

          @current_corrector ||= Corrector.new(processed_source)
        end

        private

        def applicable_document?
          path = processed_source.path
          case self.class.department.to_s
          when 'Markdown' then RuboCop::Prose::MarkdownDocument.file?(path)
          when 'Text' then RuboCop::Prose::TextDocument.file?(path)
          else RuboCop::Prose::Document.file?(path)
          end
        end

        def document
          @document ||= processed_source.prose_document(ignore_front_matter: ignore_front_matter?)
        end

        def ignore_front_matter?
          return true unless RuboCop::Prose::MarkdownDocument.file?(processed_source.path)

          ignore = config.fetch('Markdown', {}).fetch('IgnoreFrontMatter', true)
          return ignore if [true, false].include?(ignore)

          raise ValidationError, 'Markdown: IgnoreFrontMatter must be true or false.'
        end

        def investigate_document
          document.paragraphs.each { |paragraph| investigate_paragraph(paragraph) }
        end

        def range_for_original(range)
          mapping = processed_source.prose_markdown_document
          mapping ? mapping.original_range(range) : range
        end

        def processed_range(range)
          mapping = processed_source.prose_markdown_document
          mapping ? mapping.processed_range(range) : range
        end

        def prose_offense(range, **, &)
          add_offense(processed_range(range), **, &)
        end
      end
    end
  end
end
