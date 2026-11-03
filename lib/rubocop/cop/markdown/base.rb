# frozen_string_literal: true

module RuboCop
  module Cop
    module Markdown
      class Base < Prose::Base
        exclude_from_registry

        private

        def applicable_document?
          processed_source.prose_format == :markdown
        end
      end
    end
  end
end
