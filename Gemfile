# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'rake', '~> 13.0'
gem 'rspec', '~> 3.13'
gem 'rubocop', ENV.fetch('RUBOCOP_VERSION', '~> 1.72'), '>= 1.72.1'
gem 'rubocop-rake', require: false
gem 'rubocop-rspec', require: false

group :development do
  gem 'danger', require: false
  gem 'danger-changelog', require: false
  # Danger still relies on Git::Base, removed in git 6.
  gem 'git', '< 6', require: false
end
