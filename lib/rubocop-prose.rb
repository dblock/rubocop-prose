# frozen_string_literal: true

require 'rubocop'
require 'yaml'
require_relative 'rubocop/prose/version'
require_relative 'rubocop/prose/parser'
require_relative 'rubocop/prose/document'
require_relative 'rubocop/prose/source'
require_relative 'rubocop/prose/plugin'
require_relative 'rubocop/cop/prose/base'

Dir[File.join(__dir__, 'rubocop/cop/prose/*.rb')].each { |path| require path }

module RuboCop
  module Prose
    def self.default_configuration
      paths = Dir[File.expand_path('../config/{default,cops/*}.yml', __dir__)]
      paths.each_with_object({}) { |path, config| config.merge!(YAML.safe_load_file(path)) }
    end
  end
end
