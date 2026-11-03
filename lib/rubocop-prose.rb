# frozen_string_literal: true

require 'rubocop'
require 'yaml'
require_relative 'rubocop/prose/version'
require_relative 'rubocop/prose/parser'
require_relative 'rubocop/prose/file_types'
require_relative 'rubocop/prose/document'
require_relative 'rubocop/prose/markdown_document'
require_relative 'rubocop/prose/text_document'
require_relative 'rubocop/prose/source'
require_relative 'rubocop/prose/runner'
require_relative 'rubocop/prose/plugin'
require_relative 'rubocop/cop/prose/base'
require_relative 'rubocop/cop/markdown/base'
require_relative 'rubocop/cop/text/base'

Dir[File.join(__dir__, 'rubocop/cop/{prose,markdown,text}/*.rb')].each { |path| require path }

module RuboCop
  module Prose
    def self.default_configuration
      paths = Dir[File.expand_path('../config/default.yml', __dir__),
                  File.expand_path('../config/cops/**/*.yml', __dir__)]
      paths.each_with_object({}) do |path, config|
        config.merge!(YAML.safe_load_file(path)) { |_, previous, current| previous.merge(current) }
      end
    end
  end
end
