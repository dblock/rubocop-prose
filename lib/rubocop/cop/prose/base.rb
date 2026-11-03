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
          return super unless processed_source.prose_format

          @current_corrector ||= Corrector.new(processed_source)
        end

        private

        def applicable_document?
          !processed_source.prose_format.nil?
        end

        def document
          @document ||= processed_source.prose_document(configuration: config)
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
