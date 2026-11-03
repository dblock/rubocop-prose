# frozen_string_literal: true

module RuboCop
  module Cop
    module Text
      class Base < Prose::Base
        exclude_from_registry

        private

        def applicable_document?
          processed_source.prose_format == :text
        end
      end
    end
  end
end
